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
  def update(assigns, socket) do
    socket = assign(socket, assigns)

IO.puts("update ran")
IO.puts(assigns.has_won)
    if assigns.has_won do
      {:ok, socket |> assign(:edit_enemy_board, false)}
    else
      {:ok, socket}
    end
  end

  @impl true
  # this click event should always originate from current player clicking on enemy's board
  def handle_event("click", %{"row" => row, "col" => col}, socket) do
    # TODO: set timeouts so that computer takes some time to attack
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

    {:noreply,
     socket
     |> assign(:play_chance, "computer")
     |> assign(:edit_enemy_board, false)
     |> computer_chance(socket.assigns.gameboard)}
  end

  defp computer_chance(socket, player_board) do
    new_player_gameboard =
      Gameboard.attack(player_board, Computer.get_attack_position(player_board))

    send(self(), {:update_player_gameboard, %{gameboard: new_player_gameboard}})

    socket
    |> assign(:play_chance, "player")
    |> assign(:edit_enemy_board, true)
  end
end
