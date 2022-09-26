defmodule BattleshipWeb.GameLive.SingleplayerPlayComponent do
  @moduledoc """
  Component for single player playing against computer
  """
  use BattleshipWeb, :live_component

  alias Battleship.{Computer}

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

    if socket.assigns.game_over do
      {:ok, socket |> assign(:edit_enemy_board, false)}
    else
      {:ok, socket}
    end
  end

  @impl true
  # this click event should always originate from current player clicking on enemy's board
  def handle_event("click", position, socket) do
    # computer or another player will get a new chance here in this handler.
    send(self(), {:attack_enemy, %{position: position}})

    {:noreply,
     socket
     |> assign(:play_chance, "computer")
     |> assign(:edit_enemy_board, false)
     |> computer_chance(socket.assigns.gameboard)}
  end

  defp computer_chance(socket, player_board) do
    :timer.apply_after(
      900,
      BattleshipWeb.GameLive.SingleplayerPlayComponent,
      :send_computer_update,
      [
        self(),
        Computer.get_attack_position(player_board)
      ]
    )

    socket
  end

  def send_computer_update(pid, attack_position) do
    send(pid, {:attack_player, %{position: attack_position}})

    send_update(pid, BattleshipWeb.GameLive.SingleplayerPlayComponent,
      id: "play-component",
      play_chance: "player",
      edit_enemy_board: true
    )
  end
end
