defmodule BattleshipWeb.GameLive.Index do
  use BattleshipWeb, :live_view

  alias Battleship.Gameboard

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:action, :index)
     |> assign(:gameboard, Gameboard.generate_board())
     |> assign(:enemy_gameboard, %{})}
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
  def handle_info({:edit_player_gameboard, %{gameboard: gameboard}}, socket) do
    # Originates from edit component
    {:noreply, assign(socket, :gameboard, gameboard)}
  end

  @impl true
  def handle_info({:update_player_gameboard, %{gameboard: gameboard}}, socket) do
    # Originates from play component
    {:noreply, assign(socket, :gameboard, gameboard)}
  end

  @impl true
  def handle_info({:update_enemy_gameboard, %{enemy_gameboard: gameboard}}, socket) do
    # Originates from play component
    {:noreply, assign(socket, :enemy_gameboard, gameboard)}
  end
end
