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

  def set_value_in_range(matrix, value, [[start_row, start_column], [end_row, end_column]]) do
    row_range = start_row..end_row
    col_range = start_column..end_column

    if element_already_present?(matrix, row_range, col_range) do
      {:error, :element_already_present}
    else
      {:ok,
       row_range
       |> Enum.reduce(matrix, fn row, acc ->
         col_range
         |> Enum.reduce(acc, fn column, acc ->
           set(acc, value, [row, column])
         end)
       end)}
    end
  end

  defp element_already_present?(matrix, row_range, col_range) do
    Enum.any?(row_range, fn row ->
      Enum.any?(col_range, fn col -> get(matrix, [row, col]) > 0 end)
    end)
  end
end
