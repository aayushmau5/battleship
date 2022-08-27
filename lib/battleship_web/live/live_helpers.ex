defmodule BattleshipWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  alias Phoenix.LiveView.JS

  def btn(assigns) do
    ~H"""
    <%= if @disabled do %>
      <button class={@class} disabled=""><%= render_slot(@inner_block) %></button>
    <% else %>
      <button class={@class} phx-click={JS.hide(to: @to, transition: "animate-fade-out") |> JS.push(@click)}><%= render_slot(@inner_block) %></button>
    <% end %>
    """
  end
end
