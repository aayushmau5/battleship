defmodule Battleship.Gameboard do
  alias Battleship.Matrix

  def generate_board(size \\ 10), do: Matrix.generate(size)

  @doc """
  position: [start, end]
  position: [[0,0], [0,4]]
  """
  # TODO: handle map length doesn't automatically increase(maybe add a guard clause)
  def put_ship(board, ship, [start_position, end_position]),
    do: Matrix.set_value_in_range(board, ship, [start_position, end_position])

  def attack(board, [row, column]) do
    previous_value = Matrix.get(board, [row, column])
    new_board = Matrix.set(board, -1, [row, column])
    %{board: new_board, hit?: previous_value > 0}
  end

  def has_won?(board) do
    ship_present? =
      Enum.any?(board, fn {_key, row} ->
        Enum.any?(row, fn {_key, val} -> val > 0 end)
      end)

    !ship_present?
  end
end
