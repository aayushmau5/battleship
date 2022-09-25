defmodule Battleship.Computer do
  @moduledoc """
  The computer player
  """

  @board_size 10

  alias Battleship.{Gameboard, Matrix}

  def put_ship_in_random_position(board, ship, "x") do
    start_row = Enum.random(0..(@board_size - 1))
    start_col = Enum.random(0..(@board_size - 1))
    end_row = start_row
    # for x axis, row should be the same
    end_col = start_col + ship - 1

    case Gameboard.put_ship(board, ship, [[start_row, start_col], [end_row, end_col]]) do
      {:ok, gameboard} -> gameboard
      {:error, _} -> put_ship_in_random_position(board, ship, "x")
    end
  end

  def put_ship_in_random_position(board, ship, "y") do
    start_row = Enum.random(0..(@board_size - 1))
    start_col = Enum.random(0..(@board_size - 1))
    end_row = start_row + ship - 1
    # for y axis, column should be the same
    end_col = start_col

    case Gameboard.put_ship(board, ship, [[start_row, start_col], [end_row, end_col]]) do
      {:ok, gameboard} -> gameboard
      {:error, _} -> put_ship_in_random_position(board, ship, "y")
    end
  end

  defp get_random_axis, do: Enum.random(["x", "y"])

  def generate_computer_gameboard do
    Gameboard.generate_board()
    |> put_ship_in_random_position(5, get_random_axis())
    |> put_ship_in_random_position(4, get_random_axis())
    |> put_ship_in_random_position(3, get_random_axis())
    |> put_ship_in_random_position(2, get_random_axis())
  end

  def get_attack_position(player_board) do
    position = [Enum.random(0..(@board_size - 1)), Enum.random(0..(@board_size - 1))]

    # handles already attacked positions
    case Matrix.get(player_board, position) do
      -2 -> get_attack_position(player_board)
      -1 -> get_attack_position(player_board)
      _ -> %{"row" => Enum.at(position, 0), "col" => Enum.at(position, 1)}
    end
  end
end
