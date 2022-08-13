defmodule BattleshipWeb.GameLive.BoardComponent do
  use BattleshipWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <h1>Player board</h1>
      <%= for row <- 0..9 do %>
        <div class="flex gap-10">
          <%= for col <- 0..9 do %>
            <div phx-value-row={row} phx-value-col={col}><%= row %><%= col %></div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end
end
