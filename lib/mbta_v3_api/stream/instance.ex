defmodule MBTAV3API.Stream.Instance do
  use Supervisor, restart: :transient

  @opaque t :: pid()

  @type opt ::
          {:url, String.t()}
          | {:headers, [{String.t(), String.t()}]}
          | {:send_to, pid()}
          | {:type, module()}
  @type opts :: [opt()]

  @spec start_link(opts()) :: {:ok, t()} | :ignore | {:error, {:already_started, t()} | term()}
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  @spec shutdown(t(), term()) :: :ok
  def shutdown(pid, reason \\ :shutdown) do
    Supervisor.stop(pid, reason)
  end

  @impl Supervisor
  def init(opts) do
    ref = make_ref()

    url = Keyword.fetch!(opts, :url)
    headers = Keyword.fetch!(opts, :headers)
    type = Keyword.fetch!(opts, :type)
    send_to = Keyword.fetch!(opts, :send_to)

    children = [
      {MobileAppBackend.SSE,
       name: MBTAV3API.Stream.Registry.via_name(ref), url: url, headers: headers},
      {MBTAV3API.Stream.Consumer,
       subscribe_to: [{MBTAV3API.Stream.Registry.via_name(ref), []}], send_to: send_to, type: type}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
