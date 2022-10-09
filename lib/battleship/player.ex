defmodule Battleship.Player do
  @moduledoc """
  The player module
  """
  defstruct name: "", win: false, gameboard: %{}, room_id: nil

  alias Battleship.{Player, Gameboard}

  def new(name \\ "Player", gameboard \\ Gameboard.generate_board()) do
    %Player{name: name, gameboard: gameboard}
  end

  def reset_player_gameboard(player) do
    Map.update!(player, :gameboard, fn _ -> Gameboard.generate_board() end)
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
