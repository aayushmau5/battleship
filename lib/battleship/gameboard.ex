defmodule Battleship.Gameboard do
  alias Battleship.Matrix

  @board_size 10

  def generate_board, do: Matrix.generate(@board_size)

  @doc """
  position: [start, end]
  position: [[0,0], [0,4]]
  """
  def put_ship(board, ship, [start_position, end_position])
      when is_list(start_position) and is_list(end_position) do
    if in_range?(end_position, @board_size - 1) do
      Matrix.set_value_in_range(board, ship, [start_position, end_position])
    else
      {:error, :out_of_range}
    end
  end

  def attack(board, [row, column]) do
    previous_value = Matrix.get(board, [row, column])

    if previous_value == 0 do
      Matrix.set(board, -2, [row, column])
    else
      Matrix.set(board, -1, [row, column])
    end
  end

  def has_won?(board) do
    ship_present? =
      Enum.any?(board, fn {_key, row} ->
        Enum.any?(row, fn {_key, val} -> val > 0 end)
      end)

    !ship_present?
  end

  defp in_range?([row, col], limit) do
    row <= limit and col <= limit
  end
end
