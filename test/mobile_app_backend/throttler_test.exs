defmodule MobileAppBackend.ThrottlerTest do
  use ExUnit.Case, async: true

  alias MobileAppBackend.Throttler

  @timeout 10

  setup ctx do
    throttler = start_link_supervised!({Throttler, target: self(), cast: :message, ms: @timeout})

    if last_cast_ms_ago = ctx[:last_cast_ms_ago] do
      :sys.replace_state(throttler, fn state ->
        %Throttler.State{
          state
          | last_cast: System.monotonic_time(:millisecond) - last_cast_ms_ago
        }
      end)
    end

    [throttler: throttler]
  end

  test "casts instantly on first run", %{throttler: throttler} do
    Throttler.request(throttler)

    assert_receive {:"$gen_cast", :message}, 1
  end

  @tag last_cast_ms_ago: @timeout + 1
  test "casts instantly if last cast was old", %{throttler: throttler} do
    Throttler.request(throttler)

    assert_receive {:"$gen_cast", :message}, 1
  end

  @tag last_cast_ms_ago: 0
  test "casts later if last cast was recent", %{throttler: throttler} do
    Throttler.request(throttler)

    refute_receive {:"$gen_cast", :message}, @timeout - 1
    assert_receive {:"$gen_cast", :message}, 2
  end

  @tag last_cast_ms_ago: 0
  test "only casts once", %{throttler: throttler} do
    for _ <- 0..50 do
      Throttler.request(throttler)
    end

    refute_receive {:"$gen_cast", :message}, @timeout - 1
    assert_receive {:"$gen_cast", :message}, 2
    refute_receive {:"$gen_cast", :message}, @timeout
  end
end
