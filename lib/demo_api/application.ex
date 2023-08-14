defmodule DemoApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Credentials,
      # Start the Telemetry supervisor
      DemoApiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: DemoApi.PubSub},
      # Start the Endpoint (http/https)
      DemoApiWeb.Endpoint,
      # Start a worker by calling: DemoApi.Worker.start_link(arg)
      # {DemoApi.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DemoApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DemoApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
