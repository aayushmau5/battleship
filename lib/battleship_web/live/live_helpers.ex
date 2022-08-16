defmodule BattleshipWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  alias Phoenix.LiveView.JS

  def btn(assigns, click: click, class: class, disabled: disabled) do
    ~H"""
    <%= if disabled do %>
      <button class={class} disabled=""><%= assigns %></button>
    <% else %>
      <button class={class} phx-click={click}><%= assigns %></button>
    <% end %>
    """
  end
end
