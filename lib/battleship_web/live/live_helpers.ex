defmodule BattleshipWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  alias Phoenix.LiveView.JS

  def btn(assigns) do
    assigns = assign_new(assigns, :disabled, fn -> false end)

    ~H"""
    <%= if @disabled do %>
      <button class={@class} disabled=""><%= render_slot(@inner_block) %></button>
    <% else %>
      <button class={@class} phx-click={JS.hide(to: @to, transition: "fade-out", time: 500) |> JS.push(@click)}><%= render_slot(@inner_block) %></button>
    <% end %>
    """
  end
end
