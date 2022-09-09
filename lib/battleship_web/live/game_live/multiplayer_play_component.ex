defmodule BattleshipWeb.GameLive.MultiplayerPlayComponent do
  @moduledoc """
  Component for multiplayer game where players play against each other
  """
  use BattleshipWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, socket}
  end
end
