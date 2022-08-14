defmodule BattleshipWeb.GameLive.EditComponent do
  use BattleshipWeb, :live_component

  alias Battleship.{Gameboard, Ship}

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:ship, Ship.get_ship(5))
     |> assign(:axis, "x")
     |> assign(:edit, true)
     |> assign(:error, nil)}
  end

  @impl true
  def handle_event("change-axis", _, %{assigns: %{axis: "x"}} = socket),
    do: {:noreply, assign(socket, :axis, "y")}

  def handle_event("change-axis", _, %{assigns: %{axis: "y"}} = socket),
    do: {:noreply, assign(socket, :axis, "x")}

  def handle_event(
        "click",
        %{"row" => row, "col" => col},
        %{assigns: %{gameboard: gameboard, ship: ship, axis: axis}} = socket
      ) do
    case add_ship_to_gameboard(
           gameboard,
           ship,
           [String.to_integer(row), String.to_integer(col)],
           axis
         ) do
      {:ok, new_gameboard} ->
        {:noreply,
         socket |> assign(:gameboard, new_gameboard) |> assign(:error, nil) |> change_ship(ship)}

      {:error, :out_of_range} ->
        {:noreply,
         socket
         |> assign(:error, "Out of range. Please select another slot.")}
    end
  end

  defp change_ship(socket, current_ship) when current_ship > 2,
    do: assign(socket, :ship, Ship.get_ship(current_ship - 1))

  defp change_ship(socket, current_ship) when current_ship <= 2 do
    send(self(), {:updated_gameboard, %{gameboard: socket.assigns.gameboard}})
    assign(socket, :edit, false)
  end

  defp add_ship_to_gameboard(board, ship, [initial_row, inital_col], "x") do
    start_position = [initial_row, inital_col]
    end_position = [initial_row, inital_col + ship - 1]
    Gameboard.put_ship(board, ship, [start_position, end_position])
  end

  defp add_ship_to_gameboard(board, ship, [initial_row, inital_col], "y") do
    start_position = [initial_row, inital_col]
    end_position = [initial_row + ship - 1, inital_col]
    Gameboard.put_ship(board, ship, [start_position, end_position])
  end
end
