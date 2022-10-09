defmodule Battleship.Player do
  @moduledoc """
  The player module
  """
  defstruct name: "", win: false, gameboard: %{}, room_id: nil

  alias Battleship.{Player, Gameboard}

  def new(name \\ "Player") do
    %Player{name: name}
  end

  def reset_state(player) do
    player
    |> Map.update!(:gameboard, fn _ -> Gameboard.generate_board() end)
    |> Map.update!(:win, fn _ -> false end)
    |> Map.update!(:room_id, fn _ -> nil end)
  end

  @doc """
  Updates a player's gameboard
  """
  def update_player_gameboard(%Player{} = player, gameboard) do
    Map.update!(player, :gameboard, fn _ -> gameboard end)
  end

  def set_win(player, win) do
    Map.update!(player, :win, fn _ -> win end)
  end
end
