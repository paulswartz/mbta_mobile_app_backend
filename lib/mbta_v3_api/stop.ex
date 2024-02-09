defmodule MBTAV3API.Stop do
  alias MBTAV3API.JsonApi

  @behaviour JsonApi.Object

  @type t :: %__MODULE__{
          id: String.t(),
          latitude: float(),
          longitude: float(),
          name: String.t(),
          location_type: location_type(),
          parent_station: t() | JsonApi.Reference.t() | nil,
          child_stops: t() | JsonApi.Reference.t() | nil
        }
  @type location_type ::
          :stop | :station | :entrance_exit | :generic_node | :boarding_area

  @type stop_map() :: %{String.t() => __MODULE__.t()}

  @derive Jason.Encoder
  defstruct [:id, :latitude, :longitude, :name, :location_type, :parent_station, :child_stops]

  def parent(%__MODULE__{parent_station: %__MODULE__{} = parent}), do: parent
  def parent(%__MODULE__{parent_station: nil} = stop), do: stop

  @impl JsonApi.Object
  def fields, do: [:latitude, :longitude, :name, :location_type]

  @impl JsonApi.Object
  def includes,
    do: %{
      parent_station: :stop,
      child_stops: :stop
    }

  @spec get_all(JsonApi.Params.t(), Keyword.t()) :: {:ok, [t()]} | {:error, term()}
  def get_all(params, opts \\ []) do
    params = JsonApi.Params.flatten_params(params, :stop)

    case MBTAV3API.get_json("/stops", params, opts) do
      %JsonApi{data: data} -> {:ok, Enum.map(data, &parse/1)}
      {:error, error} -> {:error, error}
    end
  end

  @spec parse(JsonApi.Item.t()) :: t()
  def parse(%JsonApi.Item{} = item) do
    %__MODULE__{
      id: item.id,
      latitude: item.attributes["latitude"],
      longitude: item.attributes["longitude"],
      name: item.attributes["name"],
      location_type: parse_location_type(item.attributes["location_type"]),
      parent_station: JsonApi.Object.parse_one_related(item.relationships["parent_station"]),
      child_stops: JsonApi.Object.parse_many_related(item.relationships["child_stops"])
    }
  end

  @spec include_missing_siblings(stops :: stop_map()) :: stop_map()
  def include_missing_siblings(stops) do
    parents =
      stops
      |> Map.values()
      |> Enum.filter(&(&1.parent_station != nil))
      |> Map.new(&{&1.parent_station.id, &1.parent_station})

    missing_sibling_stops =
      parents
      |> Map.values()
      |> Enum.flat_map(& &1.child_stops)
      |> Enum.filter(
        &case &1 do
          %__MODULE__{} -> Enum.member?([:stop, :station], &1.location_type)
          _ -> false
        end
      )
      |> Enum.map(&%__MODULE__{&1 | parent_station: Map.get(parents, &1.parent_station.id)})

    Map.new(
      missing_sibling_stops ++ Map.values(stops),
      &{&1.id,
       %__MODULE__{
         &1
         | child_stops: nil,
           parent_station:
             if(&1.parent_station == nil,
               do: nil,
               else: %__MODULE__{&1.parent_station | child_stops: nil}
             )
       }}
    )
  end

  @spec parse_location_type(integer() | nil) :: location_type()
  defp parse_location_type(nil), do: :stop
  defp parse_location_type(0), do: :stop
  defp parse_location_type(1), do: :station
  defp parse_location_type(2), do: :entrance_exit
  defp parse_location_type(3), do: :generic_node
  defp parse_location_type(4), do: :boarding_area
end
