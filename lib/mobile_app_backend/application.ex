defmodule MobileAppBackend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Logger.add_handlers(:mobile_app_backend)

    children = [
      MobileAppBackendWeb.Telemetry,
      {DNSCluster,
       query: Application.get_env(:mobile_app_backend, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: MobileAppBackend.PubSub},
      MBTAV3API.Supervisor,
      # Start to serve requests, typically the last entry
      MobileAppBackendWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MobileAppBackend.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MobileAppBackendWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
