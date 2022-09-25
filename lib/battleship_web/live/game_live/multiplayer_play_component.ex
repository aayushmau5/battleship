defmodule BattleshipWeb.GameLive.MultiplayerPlayComponent do
  @moduledoc """
  Component for multiplayer game where players play against each other
  """
  use BattleshipWeb, :live_component

  alias Battleship.Gameboard

  @impl true
  def mount(socket) do
    {:ok, socket |> assign(:has_won, false)}
  end

  @impl true
  def handle_event("click", position, socket) do
    %{"row" => row, "col" => col} = position

    new_enemy_board =
      Gameboard.attack(socket.assigns.enemy_gameboard, [
        String.to_integer(row),
        String.to_integer(col)
      ])

    send(
      self(),
      {:update_multiplayer_enemy_gameboard, %{enemy_gameboard: new_enemy_board}}
    )

    Phoenix.PubSub.broadcast_from(Battleship.PubSub, self(), socket.assigns.room_id, %{
      event: "attack_player",
      position: position
    })

    {:noreply, socket}
  end
end
