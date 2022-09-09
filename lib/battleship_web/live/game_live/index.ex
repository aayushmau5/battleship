defmodule BattleshipWeb.GameLive.Index do
  use BattleshipWeb, :live_view

  alias Battleship.{Gameboard, Room}
  alias BattleshipWeb.Presence

  @player_count_topic "player"

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       action: :index,
       gameboard: Gameboard.generate_board(),
       enemy_gameboard: %{},
       has_won: false,
       winner: nil,
       multiplayer: false
     )
     |> track_player_count()}
  end

  @impl true
  def handle_event("index", _params, socket) do
    # Reset player state
    {:noreply,
     assign(socket,
       action: :index,
       gameboard: Gameboard.generate_board(),
       enemy_gameboard: %{},
       has_won: false,
       winner: nil,
       multiplayer: false
     )}
  end

  @impl true
  def handle_event("edit", _params, socket) do
    {:noreply, assign(socket, multiplayer: false, action: :edit)}
  end

  @impl true
  def handle_event("multiplayer", _params, socket) do
    {:noreply, assign(socket, multiplayer: true, action: :edit)}
  end

  @impl true
  # Handle event for multi-player game
  def handle_event("play", _params, %{assigns: %{multiplayer: true}} = socket) do
    # room_id = Room.get_room()
    room_id = "abcdef"

    {:noreply,
     socket |> assign(:room_id, room_id) |> assign(:action, :play) |> track_multiplayer(room_id)}
  end

  @impl true
  # Handle event for single player game
  def handle_event("play", _params, socket) do
    {:noreply, assign(socket, action: :play)}
  end

  @impl true
  # Originates from edit component
  def handle_info({:edit_player_gameboard, %{gameboard: gameboard}}, socket) do
    {:noreply, assign(socket, :gameboard, gameboard)}
  end

  @impl true
  # Originates from play component
  def handle_info({:update_player_gameboard, %{gameboard: gameboard}}, socket) do
    socket = assign(socket, :gameboard, gameboard)

    if Gameboard.has_won?(gameboard) do
      {:noreply, socket |> assign(:has_won, true) |> assign(:winner, "computer")}
    else
      {:noreply, socket}
    end
  end

  @impl true
  # Originates from play component
  def handle_info({:update_enemy_gameboard, %{enemy_gameboard: gameboard}}, socket) do
    socket = assign(socket, :enemy_gameboard, gameboard)

    if Gameboard.has_won?(gameboard) do
      {:noreply, socket |> assign(:has_won, true) |> assign(:winner, "player")}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}, topic: "player"},
        %{assigns: %{player_count: count}} = socket
      ) do
    count = count + map_size(joins) - map_size(leaves)
    {:noreply, assign(socket, :player_count, count)}
  end

  @impl true
  def handle_info(
        %{event: "presence_diff", payload: %{joins: _joins, leaves: _leaves}, topic: room_id},
        socket
      ) do
    count = Presence.list(room_id) |> map_size()

    if count == 2 do
      {:noreply, socket}
      # {:noreply, assign(socket, action: :play)} # when we want user to be in a "waiting" room
    else
      {:noreply, socket}
    end
  end

  defp track_player_count(socket) do
    count = Presence.list(@player_count_topic) |> map_size()

    if connected?(socket) do
      BattleshipWeb.Endpoint.subscribe(@player_count_topic)
      Presence.track(self(), @player_count_topic, socket.id, %{id: socket.id})
    end

    assign(socket, :player_count, count)
  end

  defp track_multiplayer(socket, topic) do
    # What if a user doesn't disconnect, but leaves a room just after creating a room?
    # add a check to make decision based on `Presence.list`
    BattleshipWeb.Endpoint.subscribe(topic)
    Presence.track(self(), topic, socket.id, %{room_id: topic})
    socket
  end
end
