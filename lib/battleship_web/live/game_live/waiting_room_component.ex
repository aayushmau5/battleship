defmodule BattleshipWeb.GameLive.WaitingRoomComponent do
  use BattleshipWeb, :live_component

  def render(assigns) do
    ~H"""
    <h1>Waiting for other players to join</h1>
    """
  end
end
