defmodule BattleshipWeb.GameLive.HomeComponent do
  use BattleshipWeb, :live_component

  @acceptable_name_length 25

  @impl true
  def mount(socket) do
    {:ok, assign(socket, error: nil, player_name: "", enable_change_name: false)}
  end
  
  @impl true
  def update(assigns, socket) do
    socket = socket |> assign(assigns) |> assign(error: nil, player_name: assigns.player.name) 
    {:ok, socket}
  end

  @impl true
  def handle_event("enable-name-change", _params, socket), do: {:noreply, assign(socket, enable_change_name: true)}

  @impl true
  def handle_event("change-player-name", params, socket) do
    player_name = params["player-name"] |> String.trim()
    len = String.length(player_name)

    socket =
      cond do
        len > 0 && len < @acceptable_name_length ->
          send(self(), {:change_player_name, player_name})
          assign(socket, error: nil, enable_change_name: false, player_name: player_name)

        len < 1 ->
          assign(socket, error: "Please enter a correct name", player_name: "")

        len > @acceptable_name_length ->
          assign(socket, error: "Name must be of only 25 characters", player_name: "")
      end

    {:noreply, socket}
  end
end
