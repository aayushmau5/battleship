defmodule BattleshipWeb.GameLive.MultiplayerPlayComponent do
  @moduledoc """
  Component for multiplayer game where players play against each other
  """
  use BattleshipWeb, :live_component

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_new(:edit_enemy_board, fn assigns -> assigns.first_chance end)

    {:ok, socket}
  end

  @impl true
  def handle_event("click", position, socket) do
    dbg(self())

    Phoenix.PubSub.broadcast(Battleship.PubSub, socket.assigns.room_id, %{
      event: "attack_player",
      from: self(),
      position: position
    })

    {:noreply, socket}
  end
end
