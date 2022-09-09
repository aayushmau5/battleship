defmodule Battleship.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      BattleshipWeb.Telemetry,
      Battleship.Room,
      # Start the PubSub system
      {Phoenix.PubSub, name: Battleship.PubSub},
      BattleshipWeb.Presence,
      # Start the Endpoint (http/https)
      BattleshipWeb.Endpoint
      # Start a worker by calling: Battleship.Worker.start_link(arg)
      # {Battleship.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Battleship.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BattleshipWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
