defmodule Battleship.Computer do
  @moduledoc """
  The computer player
  """

  alias Battleship.Gameboard

  def put_ships_in_random do
    matrix = Gameboard.generate_board()
  end
end
