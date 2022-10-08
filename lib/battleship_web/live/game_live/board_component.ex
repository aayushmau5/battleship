defmodule BattleshipWeb.GameLive.BoardComponent do
  @moduledoc """
  This module will be responsible for showing gameboard, showing ships or not showing them, handling edit, etc.
  """
  use BattleshipWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="my-4">
      <%= for {row, val} <- @gameboard do %>
        <div class="flex gap-1 mb-1">
          <%= for {col, value} <- val do %>
            <div
              phx-value-row={row}
              phx-value-col={col}
              class={"border p-3 md:p-4 #{assign_proper_class(assigns, value)}"}
              phx-click={assign_click(assigns, value)}
              phx-target={@target}
            ></div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  def assign_click(%{enable_edit: true}, value) do
    if value >= 0, do: "click", else: ""
  end

  def assign_click(%{enable_edit: false}, _value), do: ""

  def assign_proper_class(%{show_ships: true}, value)
      when value > 0 do
    assign_color_on_value(value)
  end

  def assign_proper_class(%{show_ships: false, enable_edit: enable_edit?}, value)
      when value > 0 do
    assign_hover_class(enable_edit?)
  end

  def assign_proper_class(%{enable_edit: enable_edit?}, 0), do: assign_hover_class(enable_edit?)
  def assign_proper_class(_, -1), do: assign_hit_class()
  def assign_proper_class(_, -2), do: assign_miss_class()

  defp assign_color_on_value(5), do: "bg-lime-400"
  defp assign_color_on_value(4), do: "bg-green-400"
  defp assign_color_on_value(3), do: "bg-cyan-400"
  defp assign_color_on_value(2), do: "bg-pink-400"

  defp assign_hit_class, do: "bg-red-400"
  defp assign_miss_class, do: "bg-slate-100"

  defp assign_hover_class(true), do: "cursor-pointer hover:bg-slate-200"
  defp assign_hover_class(false), do: ""
end
