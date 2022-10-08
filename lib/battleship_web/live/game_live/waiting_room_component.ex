defmodule BattleshipWeb.GameLive.WaitingRoomComponent do
  use BattleshipWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="text-center animate-fade-in">
      <h1>Waiting for another player to join</h1>
      <p class="my-3 font-bold">Wanna play against computer instead?</p>
      <.btn click="multiplayer-to-singleplayer" to="#waiting_component" class="text-white p-2 rounded bg-teal-600 hover:bg-teal-500 font-bold transition-all ease-linear">Play against computer</.btn>
    </div>
    """
  end
end
