defmodule MobileAppBackendWeb.VehiclesForRouteChannelTest do
  use MobileAppBackendWeb.ChannelCase

  import MBTAV3API.JsonApi.Object, only: [to_full_map: 1]
  import MobileAppBackend.Factory
  alias MBTAV3API.Stream
  alias Test.Support.FakeStaticInstance

  setup do
    {:ok, socket} = connect(MobileAppBackendWeb.UserSocket, %{})

    %{socket: socket}
  end

  test "joins ok", %{socket: socket} do
    route_id = "123"
    direction_id = 0
    vehicle = build(:vehicle, route_id: route_id, direction_id: direction_id)

    start_link_supervised!({FakeStaticInstance, topic: "vehicles", data: to_full_map([vehicle])})

    {:ok, reply, _socket} =
      subscribe_and_join(socket, "vehicles:route", %{
        "route_id" => route_id,
        "direction_id" => direction_id
      })

    assert reply == to_full_map([vehicle])
  end

  test "filters to requested data", %{socket: socket} do
    route_id = "123"
    direction_id = 0
    good_vehicle1 = build(:vehicle, route_id: route_id, direction_id: direction_id)
    good_vehicle2 = build(:vehicle, route_id: route_id, direction_id: direction_id)
    bad_vehicle1 = build(:vehicle, route_id: "NOT-#{route_id}", direction_id: direction_id)
    bad_vehicle2 = build(:vehicle, route_id: route_id, direction_id: 1 - direction_id)
    bad_vehicle3 = build(:vehicle, route_id: "NOT-#{route_id}", direction_id: 1 - direction_id)

    start_link_supervised!(
      {FakeStaticInstance,
       topic: "vehicles",
       data: to_full_map([good_vehicle1, good_vehicle2, bad_vehicle1, bad_vehicle2, bad_vehicle3])}
    )

    {:ok, reply, _socket} =
      subscribe_and_join(socket, "vehicles:route", %{
        "route_id" => route_id,
        "direction_id" => direction_id
      })

    assert reply == to_full_map([good_vehicle1, good_vehicle2])

    Stream.PubSub.broadcast!(
      "vehicles",
      {:stream_data, "vehicles",
       to_full_map([good_vehicle1, good_vehicle2, bad_vehicle1, bad_vehicle2])}
    )

    refute_push "stream_data", _

    Stream.PubSub.broadcast!(
      "vehicles",
      {:stream_data, "vehicles", to_full_map([good_vehicle1, bad_vehicle2])}
    )

    assert_push "stream_data", data
    assert data == to_full_map([good_vehicle1])
  end
end
