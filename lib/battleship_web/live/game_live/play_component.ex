defmodule BattleshipWeb.GameLive.PlayComponent do
  use BattleshipWeb, :live_component

  alias Battleship.{Gameboard, Computer}

  @impl true
  def mount(socket) do
    send(
      self(),
      {:update_enemy_gameboard, %{enemy_gameboard: Computer.generate_computer_gameboard()}}
    )

    # Give first chance to user
    {:ok, socket |> assign(:play_chance, "player") |> assign(:edit_enemy_board, true)}
  end

  @impl true
  # this "click" event doesn't really have any specific parent. Maybe see if it's beneficial to move up to the parent component?
  # don't where from where this "click" event is originated?
  def handle_event("click", %{"row" => row, "col" => col}, socket) do
    # computer or another player will get a new chance here in this handler.
    new_enemy_board =
      Gameboard.attack(socket.assigns.enemy_gameboard, [
        String.to_integer(row),
        String.to_integer(col)
      ])

    send(
      self(),
      {:update_enemy_gameboard, %{enemy_gameboard: new_enemy_board}}
    )

    # send(self(), {:computer_attack, %{position: Computer.get_attack_position()}}) # This should handle already attack positions as well.

    {:noreply,
     socket
     |> assign(:play_chance, "computer")
     |> assign(:edit_enemy_board, false)
     |> computer_chance(socket.assigns.gameboard)}
  end

  def computer_chance(socket, player_board) do
    attack_position = Computer.get_attack_position(player_board)
    new_player_gameboard = Gameboard.attack(player_board, attack_position)
    send(self(), {:update_player_gameboard, %{gameboard: new_player_gameboard}})

    socket
    |> assign(:play_chance, "player")
    |> assign(:edit_enemy_board, true)
  end
end
