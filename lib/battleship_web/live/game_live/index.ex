defmodule BattleshipWeb.GameLive.Index do
  use BattleshipWeb, :live_view

  alias Battleship.Gameboard

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:action, :index)
     |> assign(:gameboard, Gameboard.generate_board())}
  end

  @impl true
  def handle_event("index", _params, socket) do
    {:noreply,
     socket
     |> assign(:action, :index)
     |> assign(:gameboard, Gameboard.generate_board())}
  end

  @impl true
  def handle_event("edit", _params, socket) do
    {:noreply, socket |> assign(:action, :edit)}
  end

  @impl true
  def handle_event("play", _params, socket) do
    {:noreply, socket |> assign(:action, :play)}
  end

  @impl true
  def handle_info({:updated_gameboard, %{gameboard: gameboard}}, socket) do
    {:noreply, assign(socket, :gameboard, gameboard)}
  end
end
