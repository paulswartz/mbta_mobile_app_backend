defmodule MBTAV3API.Route do
  use MBTAV3API.JsonApi.Object
  require Util

  @type t :: %__MODULE__{
          id: String.t(),
          type: type(),
          color: String.t(),
          direction_names: [String.t()],
          direction_destinations: [String.t()],
          long_name: String.t(),
          short_name: String.t(),
          sort_order: String.t(),
          text_color: String.t(),
          route_pattern_ids: [String.t()]
        }

  Util.declare_enum(
    :type,
    Util.enum_values(:index, [:light_rail, :heavy_rail, :commuter_rail, :bus, :ferry])
  )

  @derive Jason.Encoder
  defstruct [
    :id,
    :type,
    :color,
    :direction_names,
    :direction_destinations,
    :long_name,
    :short_name,
    :sort_order,
    :text_color,
    :route_pattern_ids
  ]

  @impl JsonApi.Object
  def fields,
    do: [
      :type,
      :color,
      :direction_names,
      :direction_destinations,
      :long_name,
      :short_name,
      :sort_order,
      :text_color
    ]

  @impl JsonApi.Object
  def includes, do: %{route_patterns: MBTAV3API.RoutePattern}

  @impl JsonApi.Object
  def serialize_filter_value(:type, type), do: serialize_type(type)
  def serialize_filter_value(_field, value), do: value

  @spec parse(JsonApi.Item.t()) :: t()
  def parse(%JsonApi.Item{} = item) do
    %__MODULE__{
      id: item.id,
      type:
        if type = item.attributes["type"] do
          parse_type(type)
        end,
      color: item.attributes["color"],
      direction_names: item.attributes["direction_names"],
      direction_destinations: item.attributes["direction_destinations"],
      long_name: item.attributes["long_name"],
      short_name: item.attributes["short_name"],
      sort_order: item.attributes["sort_order"],
      text_color: item.attributes["text_color"],
      route_pattern_ids: JsonApi.Object.get_many_ids(item.relationships["route_patterns"])
    }
  end
end
