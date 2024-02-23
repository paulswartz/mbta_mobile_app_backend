defmodule MBTAV3API.Prediction do
  use MBTAV3API.JsonApi.Object, renames: %{revenue_status: :revenue}
  require Util

  @type t :: %__MODULE__{
          id: String.t(),
          arrival_time: DateTime.t() | nil,
          departure_time: DateTime.t() | nil,
          direction_id: 0 | 1,
          revenue: boolean(),
          schedule_relationship: schedule_relationship(),
          status: String.t(),
          stop_sequence: integer() | nil,
          stop: MBTAV3API.Stop.t() | JsonApi.Reference.t() | nil,
          trip: MBTAV3API.Trip.t() | JsonApi.Reference.t() | nil,
          vehicle: MBTAV3API.Vehicle.t() | JsonApi.Reference.t() | nil
        }
  Util.declare_enum(
    :schedule_relationship,
    Util.enum_values(
      :uppercase_string,
      [:added, :cancelled, :no_data, :skipped, :unscheduled]
    ) ++ [scheduled: nil]
  )

  @derive Jason.Encoder
  defstruct [
    :id,
    :arrival_time,
    :departure_time,
    :direction_id,
    :revenue,
    :schedule_relationship,
    :status,
    :stop_sequence,
    :stop,
    :trip,
    :vehicle
  ]

  def fields do
    [
      :arrival_time,
      :departure_time,
      :direction_id,
      :revenue_status,
      :schedule_relationship,
      :status,
      :stop_sequence
    ]
  end

  def includes, do: %{stop: MBTAV3API.Stop, trip: MBTAV3API.Trip, vehicle: MBTAV3API.Vehicle}

  @spec stream_all(JsonApi.Params.t(), Keyword.t()) ::
          MBTAV3API.Stream.Supervisor.on_start_instance()
  def stream_all(params, opts \\ []) do
    params = JsonApi.Params.flatten_params(params, __MODULE__)
    opts = Keyword.put(opts, :type, __MODULE__)

    MBTAV3API.start_stream("/predictions", params, opts)
  end

  @spec parse(JsonApi.Item.t()) :: t()
  def parse(%JsonApi.Item{} = item) do
    %__MODULE__{
      id: item.id,
      arrival_time: Util.parse_optional_datetime!(item.attributes["arrival_time"]),
      departure_time: Util.parse_optional_datetime!(item.attributes["departure_time"]),
      direction_id: item.attributes["direction_id"],
      revenue: parse_revenue_status(item.attributes["revenue_status"]),
      schedule_relationship:
        parse_schedule_relationship(item.attributes["schedule_relationship"]),
      stop_sequence: item.attributes["stop_sequence"],
      status: item.attributes["status"],
      stop: JsonApi.Object.parse_one_related(item.relationships["stop"]),
      trip: JsonApi.Object.parse_one_related(item.relationships["trip"]),
      vehicle: JsonApi.Object.parse_one_related(item.relationships["vehicle"])
    }
  end

  @spec parse_revenue_status(String.t() | nil) :: boolean()
  defp parse_revenue_status("REVENUE"), do: true
  defp parse_revenue_status("NON_REVENUE"), do: false
  defp parse_revenue_status(nil), do: true
end
