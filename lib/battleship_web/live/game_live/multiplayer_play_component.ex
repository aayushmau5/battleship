defmodule BattleshipWeb.GameLive.MultiplayerPlayComponent do
  @moduledoc """
  Component for multiplayer game where players play against each other
  """
  use BattleshipWeb, :live_component

  @impl true
  def handle_event("click", position, socket) do
    send(self(), {:attack_opponent, %{position: position}})

    Phoenix.PubSub.broadcast_from(Battleship.PubSub, self(), socket.assigns.player.room_id, %{
      event: "attack_player",
      position: position
    })

    {:noreply, socket}
  end
end
