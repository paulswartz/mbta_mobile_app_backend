defmodule MBTAV3API.Stream.State do
  @moduledoc """
  Tracks the state of the world as remembered by a `MBTAV3API.Stream.Consumer`.

  Objects are grouped first by type and then by ID,
  to simplify both resolving references and querying all objects by type.

  Implements `Access` returning an empty map for previously unused types,
  so that, e.g., `put_in/2` works whether an object's type has been seen before or not.
  """

  alias MBTAV3API.JsonApi
  import MBTAV3API.JsonApi.Object, only: [is_json_object: 1]

  @behaviour Access

  defstruct data: %{}

  @opaque t :: %__MODULE__{data: %{module() => %{String.t() => JsonApi.Object.t()}}}

  @spec new :: t()
  def new, do: %__MODULE__{data: %{}}

  @spec apply_events(t(), [ServerSentEventStage.Event.t()]) :: t()
  def apply_events(state, events) do
    for %ServerSentEventStage.Event{event: event, data: data} <- events, reduce: state do
      state ->
        %JsonApi{data: data} = JsonApi.parse(data)
        data = Enum.map(data, &JsonApi.Object.parse/1)

        case event do
          "reset" ->
            Enum.into(data, new())

          "add" ->
            [%module{id: id} = object] = data
            put_in(state[module][id], resolve_references(object, state))

          "update" ->
            [%module{id: id} = object] = data
            put_in(state[module][id], resolve_references(object, state))

          "remove" ->
            [%JsonApi.Reference{type: type, id: id}] = data
            module = JsonApi.Object.module_for(type)
            {_, state} = pop_in(state[module][id])
            state
        end
    end
  end

  @spec values_of_type(t(), module()) :: [JsonApi.Object.t()]
  def values_of_type(state, type), do: Map.values(state[type])

  defp resolve_references(%JsonApi.Reference{type: type, id: id} = ref, state) do
    case state[JsonApi.Object.module_for(type)][id] do
      nil -> ref
      object when is_struct(object) -> object
    end
  end

  defp resolve_references(object, state) when is_json_object(object) do
    %module{} = object

    object
    |> Map.from_struct()
    |> Map.new(fn {k, v} -> {k, resolve_references(v, state)} end)
    |> then(&struct!(module, &1))
  end

  defp resolve_references(object, state) when is_list(object) do
    Enum.map(object, &resolve_references(&1, state))
  end

  defp resolve_references(object, _state)
       when is_atom(object)
       when is_binary(object)
       when is_number(object)
       when is_struct(object),
       do: object

  @impl Access
  def fetch(state, key) do
    {:ok, Map.get(state.data, key, %{})}
  end

  @impl Access
  def get_and_update(state, key, function) do
    {result, data} = Map.get_and_update(state.data, key, &function.(&1 || %{}))
    {result, %__MODULE__{data: data}}
  end

  @impl Access
  def pop(state, key) do
    {result, data} = Map.pop(state.data, key)
    {result, %__MODULE__{data: data}}
  end

  defimpl Collectable do
    def into(state) do
      initial_acc = state

      collector_fun = fn
        acc, {:cont, %module{id: id} = elem} -> put_in(acc[module][id], elem)
        acc, :done -> acc
        _acc, :halt -> :ok
      end

      {initial_acc, collector_fun}
    end
  end
end
