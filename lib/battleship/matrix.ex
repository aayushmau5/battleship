defmodule Battleship.Matrix do
  @moduledoc """
  This module is a helper that allows us to work with multi-dimensional matrices, which is implemented using a map.
  """

  def generate(length, inital_value \\ 0) do
    0..(length - 1)
    |> Enum.reduce(%{}, fn row, acc ->
      row_value =
        Enum.reduce(0..(length - 1), %{}, fn col, acc -> Map.put(acc, col, inital_value) end)

      Map.put(acc, row, row_value)
    end)
  end

  def get(matrix, position) when is_list(position) do
    get_in(matrix, position)
  end

  def set(matrix, value, position) when is_list(position) do
    put_in(matrix, position, value)
  end

  def set_value_in_range(matrix, value, [start_position, end_position]) do
    [start_row, start_column] = start_position
    [end_row, end_column] = end_position

    start_row..end_row
    |> Enum.reduce(matrix, fn row, acc ->
      start_column..end_column
      |> Enum.reduce(acc, fn column, acc ->
        set(acc, value, [row, column])
      end)
    end)
  end
end
