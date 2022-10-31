defmodule BattleshipWeb.GameLive.HowToComponent do
  use BattleshipWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="text-center animate-fade-in" id="howto-component">
      <h1 class="font-bold text-xl">How to play?</h1>
      <p class="my-4"><em>From wikipedia: </em>Battleship is a strategy type guessing game for two players. It is played on ruled grids (paper or board) on which each player's fleet of warships are marked. The locations of the fleets are concealed from the other player. Players alternate turns calling "shots" at the other player's ships, and the objective of the game is to destroy the opposing player's fleet.</p>
      <ol class="list-decimal text-left">
        <li class="mb-2">Once you click play, you will be taken to your gameboard where you have to place your ships. There are 4 types of ships with length: 5, 4, 3 and 2. You can place those vertically(Y axis) or horizontally(X axis).</li>
        <li class="mb-2">Once you are done with placing ships, click on play. You will either play against a computer or another player(if there are no other players, you will be taken to a waiting room).</li>
        <li class="mb-2">You take chances trying to guess where your opponent has placed their ships, and fire a shot.</li>
        <li class="mb-2">Once a player sinks all their opponent's ships, they win!</li>
      </ol>
      <p class="font-bold my-4">Ready?</p>
      <div class="flex gap-4 justify-center flex-wrap">
        <.btn click="singleplayer" to="#howto-component" class="text-white p-2 rounded bg-teal-600 hover:bg-teal-500 font-bold transition-all ease-linear">Play against computer</.btn>
        <.btn click="multiplayer-choice" to="#howto-component" class="text-white p-2 rounded bg-teal-600 hover:bg-teal-500 font-bold transition-all ease-linear">Play against another player</.btn>
      </div>
    </div>
    """
  end
end
