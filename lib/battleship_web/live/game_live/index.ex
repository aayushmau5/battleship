defmodule BattleshipWeb.GameLive.Index do
  use BattleshipWeb, :live_view

  alias Battleship.Gameboard

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:action, :index)
     |> assign(:gameboard, Gameboard.generate_board())
     |> assign(:enemy_gameboard, %{})
     |> assign(:has_won, false)
     |> assign(:winner, nil)}
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
  # Originates from edit component
  def handle_info({:edit_player_gameboard, %{gameboard: gameboard}}, socket) do
    {:noreply, assign(socket, :gameboard, gameboard)}
  end

  @impl true
  # Originates from play component
  def handle_info({:update_player_gameboard, %{gameboard: gameboard}}, socket) do
    socket = assign(socket, :gameboard, gameboard)

    if Gameboard.has_won?(gameboard) do
      {:noreply, socket |> assign(:has_won, true) |> assign(:winner, "computer")}
    else
      {:noreply, socket}
    end
  end

  @impl true
  # Originates from play component
  def handle_info({:update_enemy_gameboard, %{enemy_gameboard: gameboard}}, socket) do
    socket = assign(socket, :enemy_gameboard, gameboard)

    if Gameboard.has_won?(gameboard) do
      {:noreply, socket |> assign(:has_won, true) |> assign(:winner, "player")}
    else
      {:noreply, socket}
    end
  end
end
