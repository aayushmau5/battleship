defmodule Battleship.Player do
  @moduledoc """
  The player module
  """
  defstruct name: "", win: false, gameboard: %{}, room_id: nil, chance: false, in_game: false

  alias Battleship.{Player, Gameboard}

  def new(name \\ "Player") do
    %Player{name: name}
  end

  def reset_state(player) do
    # TODO: replace multiple Map.update! calls with one single function
    player
    |> Map.update!(:gameboard, fn _ -> Gameboard.generate_board() end)
    |> Map.update!(:win, fn _ -> false end)
    |> Map.update!(:room_id, fn _ -> nil end)
    |> Map.update!(:chance, fn _ -> false end)
    |> Map.update!(:in_game, fn _ -> false end)
  end

  @doc """
  Updates a player's gameboard
  """
  def update_player_gameboard(%Player{} = player, gameboard) do
    Map.update!(player, :gameboard, fn _ -> gameboard end)
  end

  def update_room_id(player, room_id) do
    Map.update!(player, :room_id, fn _ -> room_id end)
  end

  def set_win(player, win) do
    Map.update!(player, :win, fn _ -> win end)
  end

  def update_player_chance(player, chance) do
    Map.update!(player, :chance, fn _ -> chance end)
  end

  def update_player_status(player, status) do
    Map.update!(player, :in_game, fn _ -> status end)
  end
end
