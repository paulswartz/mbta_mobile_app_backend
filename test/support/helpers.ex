defmodule Test.Support.Helpers do
  @moduledoc "Test helpers"

  alias Test.Support.Helpers
  alias Test.Support.MockApiData

  defmacro reassign_env(app, var, value) do
    quote do
      old_value = Application.get_env(unquote(app), unquote(var))
      Application.put_env(unquote(app), unquote(var), unquote(value))

      on_exit(fn ->
        if old_value == nil do
          Application.delete_env(unquote(app), unquote(var))
        else
          Application.put_env(unquote(app), unquote(var), old_value)
        end
      end)
    end
  end

  defmacro bypass_api(opts \\ []) do
    use_mock_data = Keyword.get(opts, :use_mock_data, true)

    quote do
      bypass = Bypass.open()

      Helpers.reassign_env(
        :mobile_app_backend,
        :base_url,
        "http://localhost:#{bypass.port}"
      )

      if unquote(use_mock_data) do
        MockApiData.mount(bypass)
      end

      bypass
    end
  end

  defmacro set_log_level(log_level) do
    quote do
      old_log_level = Logger.level()

      on_exit(fn ->
        Logger.configure(level: old_log_level)
      end)

      Logger.configure(level: unquote(log_level))
    end
  end
end
