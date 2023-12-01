defmodule MobileAppBackendWeb.SchemaTest do
  use MobileAppBackendWeb.ConnCase

  import Test.Support.Helpers

  @stop_query """
  query {
    stop(id: "place-boyls") {
      id
      name
      routes {
        id
        name
        routePatterns {
          id
          name
        }
      }
    }
  }
  """

  test "query: stop", %{conn: conn} do
    bypass = bypass_api()

    Bypass.expect(bypass, "GET", "/stops/place-boyls", fn conn ->
      Phoenix.Controller.json(conn, %{
        data: %{
          attributes: %{
            address: "Boylston St and Tremont St, Boston, MA",
            description: nil,
            latitude: 42.35302,
            location_type: 1,
            longitude: -71.06459,
            municipality: "Boston",
            name: "Boylston",
            platform_code: nil,
            platform_name: nil,
            wheelchair_boarding: 2
          },
          id: "place-boyls",
          links: %{self: "/stops/place-boyls"},
          relationships: %{
            child_stops: %{
              data: [
                %{id: "70158", type: "stop"},
                %{id: "70159", type: "stop"}
              ]
            },
            facilities: %{
              data: [],
              links: %{related: "/facilities/?filter[stop]=place-boyls"}
            },
            parent_station: %{data: nil},
            zone: %{data: nil}
          },
          type: "stop"
        },
        included: [
          %{
            attributes: %{
              address: nil,
              description: "Boylston - Green Line - Park Street & North",
              latitude: 42.352531,
              location_type: 0,
              longitude: -71.064682,
              municipality: "Boston",
              name: "Boylston",
              platform_code: nil,
              platform_name: "Park Street & North",
              wheelchair_boarding: 2
            },
            id: "70158",
            links: %{self: "/stops/70158"},
            relationships: %{
              facilities: %{links: %{related: "/facilities/?filter[stop]=70158"}},
              parent_station: %{data: %{id: "place-boyls", type: "stop"}},
              zone: %{data: %{id: "RapidTransit", type: "zone"}}
            },
            type: "stop"
          },
          %{
            attributes: %{
              address: nil,
              description: "Boylston - Green Line - Copley & West",
              latitude: 42.353214,
              location_type: 0,
              longitude: -71.064545,
              municipality: "Boston",
              name: "Boylston",
              platform_code: nil,
              platform_name: "Copley & West",
              wheelchair_boarding: 2
            },
            id: "70159",
            links: %{self: "/stops/70159"},
            relationships: %{
              facilities: %{links: %{related: "/facilities/?filter[stop]=70159"}},
              parent_station: %{data: %{id: "place-boyls", type: "stop"}},
              zone: %{data: %{id: "RapidTransit", type: "zone"}}
            },
            type: "stop"
          }
        ],
        jsonapi: %{version: "1.0"}
      })
    end)

    Bypass.expect(bypass, "GET", "/routes/", fn conn ->
      Phoenix.Controller.json(conn, %{
        data: [
          %{
            attributes: %{
              color: "00843D",
              description: "Rapid Transit",
              direction_destinations: ["Boston College", "Government Center"],
              direction_names: ["West", "East"],
              fare_class: "Rapid Transit",
              long_name: "Green Line B",
              short_name: "B",
              sort_order: 10_032,
              text_color: "FFFFFF",
              type: 0
            },
            id: "Green-B",
            links: %{self: "/routes/Green-B"},
            relationships: %{
              line: %{data: %{id: "line-Green", type: "line"}},
              route_patterns: %{
                data: [
                  %{id: "Green-B-812-0", type: "route_pattern"},
                  %{id: "Green-B-812-1", type: "route_pattern"}
                ]
              }
            },
            type: "route"
          },
          %{
            attributes: %{
              color: "00843D",
              description: "Rapid Transit",
              direction_destinations: ["Cleveland Circle", "Government Center"],
              direction_names: ["West", "East"],
              fare_class: "Rapid Transit",
              long_name: "Green Line C",
              short_name: "C",
              sort_order: 10_033,
              text_color: "FFFFFF",
              type: 0
            },
            id: "Green-C",
            links: %{self: "/routes/Green-C"},
            relationships: %{
              line: %{data: %{id: "line-Green", type: "line"}},
              route_patterns: %{
                data: [
                  %{id: "Green-C-832-0", type: "route_pattern"},
                  %{id: "Green-C-832-1", type: "route_pattern"}
                ]
              }
            },
            type: "route"
          },
          %{
            attributes: %{
              color: "00843D",
              description: "Rapid Transit",
              direction_destinations: ["Riverside", "Union Square"],
              direction_names: ["West", "East"],
              fare_class: "Rapid Transit",
              long_name: "Green Line D",
              short_name: "D",
              sort_order: 10_034,
              text_color: "FFFFFF",
              type: 0
            },
            id: "Green-D",
            links: %{self: "/routes/Green-D"},
            relationships: %{
              line: %{data: %{id: "line-Green", type: "line"}},
              route_patterns: %{
                data: [
                  %{id: "Green-D-855-0", type: "route_pattern"},
                  %{id: "Green-D-855-1", type: "route_pattern"}
                ]
              }
            },
            type: "route"
          },
          %{
            attributes: %{
              color: "00843D",
              description: "Rapid Transit",
              direction_destinations: ["Heath Street", "Medford/Tufts"],
              direction_names: ["West", "East"],
              fare_class: "Rapid Transit",
              long_name: "Green Line E",
              short_name: "E",
              sort_order: 10_035,
              text_color: "FFFFFF",
              type: 0
            },
            id: "Green-E",
            links: %{self: "/routes/Green-E"},
            relationships: %{
              line: %{data: %{id: "line-Green", type: "line"}},
              route_patterns: %{
                data: [
                  %{id: "Green-E-886-0", type: "route_pattern"},
                  %{id: "Green-E-886-1", type: "route_pattern"}
                ]
              }
            },
            type: "route"
          }
        ],
        included: [
          %{
            attributes: %{
              canonical: true,
              direction_id: 0,
              name: "Government Center - Boston College",
              sort_order: 100_320_000,
              time_desc: nil,
              typicality: 1
            },
            id: "Green-B-812-0",
            links: %{self: "/route_patterns/Green-B-812-0"},
            relationships: %{
              representative_trip: %{data: %{id: "canonical-Green-B-C1-0", type: "trip"}},
              route: %{data: %{id: "Green-B", type: "route"}}
            },
            type: "route_pattern"
          },
          %{
            attributes: %{
              canonical: true,
              direction_id: 0,
              name: "Medford/Tufts - Heath Street",
              sort_order: 100_350_000,
              time_desc: nil,
              typicality: 1
            },
            id: "Green-E-886-0",
            links: %{self: "/route_patterns/Green-E-886-0"},
            relationships: %{
              representative_trip: %{data: %{id: "canonical-Green-E-C1-0", type: "trip"}},
              route: %{data: %{id: "Green-E", type: "route"}}
            },
            type: "route_pattern"
          },
          %{
            attributes: %{
              canonical: true,
              direction_id: 0,
              name: "Government Center - Cleveland Circle",
              sort_order: 100_330_000,
              time_desc: nil,
              typicality: 1
            },
            id: "Green-C-832-0",
            links: %{self: "/route_patterns/Green-C-832-0"},
            relationships: %{
              representative_trip: %{data: %{id: "canonical-Green-C-C1-0", type: "trip"}},
              route: %{data: %{id: "Green-C", type: "route"}}
            },
            type: "route_pattern"
          },
          %{
            attributes: %{
              canonical: true,
              direction_id: 1,
              name: "Heath Street - Medford/Tufts",
              sort_order: 100_351_000,
              time_desc: nil,
              typicality: 1
            },
            id: "Green-E-886-1",
            links: %{self: "/route_patterns/Green-E-886-1"},
            relationships: %{
              representative_trip: %{data: %{id: "canonical-Green-E-C1-1", type: "trip"}},
              route: %{data: %{id: "Green-E", type: "route"}}
            },
            type: "route_pattern"
          },
          %{
            attributes: %{
              canonical: true,
              direction_id: 1,
              name: "Boston College - Government Center",
              sort_order: 100_321_000,
              time_desc: nil,
              typicality: 1
            },
            id: "Green-B-812-1",
            links: %{self: "/route_patterns/Green-B-812-1"},
            relationships: %{
              representative_trip: %{data: %{id: "canonical-Green-B-C1-1", type: "trip"}},
              route: %{data: %{id: "Green-B", type: "route"}}
            },
            type: "route_pattern"
          },
          %{
            attributes: %{
              canonical: true,
              direction_id: 1,
              name: "Riverside - Union Square",
              sort_order: 100_341_000,
              time_desc: nil,
              typicality: 1
            },
            id: "Green-D-855-1",
            links: %{self: "/route_patterns/Green-D-855-1"},
            relationships: %{
              representative_trip: %{data: %{id: "canonical-Green-D-C1-1", type: "trip"}},
              route: %{data: %{id: "Green-D", type: "route"}}
            },
            type: "route_pattern"
          },
          %{
            attributes: %{
              canonical: true,
              direction_id: 1,
              name: "Cleveland Circle - Government Center",
              sort_order: 100_331_000,
              time_desc: nil,
              typicality: 1
            },
            id: "Green-C-832-1",
            links: %{self: "/route_patterns/Green-C-832-1"},
            relationships: %{
              representative_trip: %{data: %{id: "canonical-Green-C-C1-1", type: "trip"}},
              route: %{data: %{id: "Green-C", type: "route"}}
            },
            type: "route_pattern"
          },
          %{
            attributes: %{
              canonical: true,
              direction_id: 0,
              name: "Union Square - Riverside",
              sort_order: 100_340_000,
              time_desc: nil,
              typicality: 1
            },
            id: "Green-D-855-0",
            links: %{self: "/route_patterns/Green-D-855-0"},
            relationships: %{
              representative_trip: %{data: %{id: "canonical-Green-D-C1-0", type: "trip"}},
              route: %{data: %{id: "Green-D", type: "route"}}
            },
            type: "route_pattern"
          }
        ],
        jsonapi: %{version: "1.0"}
      })
    end)

    conn =
      post(conn, "/graphql", %{
        "query" => @stop_query
      })

    assert %{"data" => %{"stop" => stop_data}} = json_response(conn, 200)
    assert %{"id" => "place-boyls", "name" => "Boylston", "routes" => routes} = stop_data

    routes = Enum.sort_by(routes, & &1["id"])

    assert routes |> Enum.map(& &1["id"]) == [
             "Green-B",
             "Green-C",
             "Green-D",
             "Green-E"
           ]

    assert %{
             "id" => "Green-B",
             "name" => "Green Line B",
             "routePatterns" => route_patterns
           } = hd(routes)

    assert length(route_patterns) > 0
  end
end
