defmodule MBTAV3API.JsonApi.Item do
  @moduledoc """
  JSON API results data.
  """
  @derive Jason.Encoder

  defstruct [:type, :id, :attributes, :relationships]

  @type t :: %__MODULE__{
          type: String.t(),
          id: String.t(),
          attributes: %{String.t() => any},
          relationships: %{String.t() => list(t())}
        }
end

defmodule MBTAV3API.JsonApi.Error do
  @moduledoc """
  JSON API error data.
  """
  @derive Jason.Encoder

  defstruct [:code, :source, :detail, :meta]

  @type t :: %__MODULE__{
          code: String.t() | nil,
          source: String.t() | nil,
          detail: String.t() | nil,
          meta: %{String.t() => any}
        }
end

defmodule MBTAV3API.JsonApi do
  @moduledoc """
  Helpers for working with a JSON API.
  """
  @derive Jason.Encoder

  defstruct links: %{}, data: []

  @type t :: %__MODULE__{
          links: %{String.t() => String.t()},
          data: list(MBTAV3API.JsonApi.Item.t())
        }

  @spec empty() :: t()
  def empty do
    %__MODULE__{
      links: %{},
      data: []
    }
  end

  @spec merge(t(), t()) :: t()
  def merge(j1, j2) do
    %__MODULE__{
      links: Map.merge(j1.links, j2.links),
      data: j1.data ++ j2.data
    }
  end

  @spec parse(String.t()) :: t() | {:error, any}
  def parse(body) do
    with {:ok, parsed} <- Jason.decode(body),
         {:ok, data} <- parse_data(parsed) do
      %__MODULE__{
        links: parse_links(parsed),
        data: data
      }
    else
      {:error, [_ | _] = errors} ->
        {:error, parse_errors(errors)}

      error ->
        error
    end
  end

  @spec parse_links(term()) :: %{String.t() => String.t()}
  defp parse_links(%{"links" => links}) do
    links
    |> Enum.filter(fn {key, value} -> is_binary(key) && is_binary(value) end)
    |> Enum.into(%{})
  end

  defp parse_links(_) do
    %{}
  end

  @spec parse_data(term()) :: {:ok, [MBTAV3API.JsonApi.Item.t()]} | {:error, any}
  defp parse_data(%{"data" => data} = parsed) when is_list(data) do
    included = parse_included(parsed)
    {:ok, Enum.map(data, &parse_data_item(&1, included))}
  end

  defp parse_data(%{"data" => data} = parsed) do
    included = parse_included(parsed)
    {:ok, [parse_data_item(data, included)]}
  end

  defp parse_data(%{"errors" => errors}) do
    {:error, errors}
  end

  defp parse_data(data) when is_list(data) do
    # MBTAV3API.Stream receives :reset data as a list of items
    parse_data(%{"data" => data})
  end

  defp parse_data(%{"id" => _} = data) do
    # MBTAV3API.Stream receives :add, :update, and :remove data as single items
    parse_data(%{"data" => data})
  end

  defp parse_data(%{}) do
    {:error, :invalid}
  end

  def parse_data_item(%{"type" => type, "id" => id, "attributes" => attributes} = item, included) do
    %MBTAV3API.JsonApi.Item{
      type: type,
      id: id,
      attributes: attributes,
      relationships: load_relationships(item["relationships"], included)
    }
  end

  def parse_data_item(%{"type" => type, "id" => id}, _) do
    %MBTAV3API.JsonApi.Item{
      type: type,
      id: id
    }
  end

  defp load_relationships(nil, _) do
    %{}
  end

  defp load_relationships(%{} = relationships, included) do
    relationships
    |> map_values(&load_single_relationship(&1, included))
  end

  defp map_values(map, f) do
    map
    |> Map.new(fn {key, value} -> {key, f.(value)} end)
  end

  defp load_single_relationship(relationship, _) when relationship == %{} do
    []
  end

  defp load_single_relationship(%{"data" => data}, included) when is_list(data) do
    data
    |> Enum.map(&match_included(&1, included))
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&parse_data_item(&1, included))
  end

  defp load_single_relationship(%{"data" => %{} = data}, included) do
    case data |> match_included(included) do
      nil -> []
      item -> [parse_data_item(item, included)]
    end
  end

  defp load_single_relationship(_, _) do
    []
  end

  defp match_included(nil, _) do
    nil
  end

  defp match_included(%{"type" => type, "id" => id} = item, included) do
    Map.get(included, {type, id}, item)
  end

  defp parse_included(params) do
    included = Map.get(params, "included", [])

    data =
      case Map.get(params, "data") do
        nil -> []
        list when is_list(list) -> list
        item -> [item]
      end

    data = Enum.map(data, fn item -> Map.delete(item, "relationships") end)

    included
    |> Enum.concat(data)
    |> Map.new(fn %{"type" => type, "id" => id} = item ->
      {{type, id}, item}
    end)
  end

  defp parse_errors(errors) do
    Enum.map(errors, &parse_error/1)
  end

  defp parse_error(error) do
    %MBTAV3API.JsonApi.Error{
      code: error["code"],
      detail: error["detail"],
      source: error["source"],
      meta: error["meta"] || %{}
    }
  end
end
