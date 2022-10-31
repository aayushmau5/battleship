defmodule BattleshipWeb.GameLive.MultiplayerChoiceComponent do
  use BattleshipWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="animate-fade-in" id="multiplayer-choice-component">
      <h1 class="text-center">Play with another player</h1>
      <.btn click="multiplayer" to="#multiplayer-choice-component" class="mt-6 text-white p-2 rounded bg-teal-600 hover:bg-teal-500 font-bold transition-all ease-linear block mx-auto">Play against any player</.btn>
      <p class="font-bold text-xl text-center my-6">OR</p>
      <.btn click="private-room" to="#multiplayer-choice-component" class="text-white p-2 rounded bg-teal-600 hover:bg-teal-500 font-bold transition-all ease-linear block mx-auto">Create/Join private room</.btn>


      <.btn click="index" to="#multiplayer-choice-component" class="mt-6 text-white p-2 rounded bg-teal-600 hover:bg-teal-500 font-bold transition-all ease-linear block mx-auto">Back</.btn>
    </div>
    """
  end
end
