defmodule MySystem.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    config =
      :my_system
      |> Application.get_all_env()
      |> Map.new()
      |> inspect()

    Logger.info("Starting #{__MODULE__}", config: config, env: inspect(System.get_env()))

    # TODO: OTel setup
    # "file=/app/deps/opentelemetry/src/otel_exporter.erl mfa=:otel_exporter.init/1 [warning] OTLP exporter failed to initialize with exception :error:{:badmatch, {:error, :inets_not_started}}
    :ok = OpentelemetryBandit.setup(opt_in_attrs: [])
    :ok = OpentelemetryPhoenix.setup(adapter: :bandit)

    MySystem.LoadControl.set_num_schedulers(1)

    children = [
      MySystem.ClusterMonitor,
      MySystem.LoadControl,
      MySystemWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:my_system, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: MySystem.PubSub},
      MySystem.Math,
      {MySystemWeb.Endpoint, http: [port: 4001]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MySystem.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MySystemWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
