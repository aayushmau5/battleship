defmodule BattleshipWeb.GameLive.BoardComponent do
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
              class={"border p-4 #{assign_class_on_value(value, assigns.enable_edit)}"}
              phx-click={if @enable_edit, do: "click", else: ""}
              phx-target={@target}
            ></div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  defp assign_class_on_value(-1, _), do: "bg-slate-100"
  defp assign_class_on_value(5, _), do: "bg-lime-300"
  defp assign_class_on_value(4, _), do: "bg-green-300"
  defp assign_class_on_value(3, _), do: "bg-cyan-300"
  defp assign_class_on_value(2, _), do: "bg-pink-300"
  defp assign_class_on_value(_, true), do: "cursor-pointer hover:bg-slate-100"
  defp assign_class_on_value(_, false), do: ""
end
