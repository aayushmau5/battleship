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
       game_over: false,
       win: false,
       winner: nil,
       multiplayer: false,
       player_left: false
     )
     |> track_player_count()}
  end

  @impl true
  def handle_event("index", _params, socket) do
    if socket.assigns.multiplayer do
      BattleshipWeb.Endpoint.unsubscribe(socket.assigns.room_id)
      Presence.untrack(self(), socket.assigns.room_id, socket.id)
    end

    # Reset player state
    {:noreply,
     assign(socket,
       action: :index,
       gameboard: Gameboard.generate_board(),
       enemy_gameboard: %{},
       game_over: false,
       win: false,
       winner: nil,
       multiplayer: false,
       player_left: false
     )}
  end

  @impl true
  def handle_event("howto", _params, socket),
    do: {:noreply, assign(socket, action: :howto)}

  @impl true
  def handle_event("edit", _params, socket),
    do: {:noreply, assign(socket, action: :edit)}

  @impl true
  def handle_event("multiplayer", _params, socket),
    do: {:noreply, assign(socket, multiplayer: true, action: :edit)}

  @impl true
  # Handle event for multi-player game
  def handle_event("play", _params, %{assigns: %{multiplayer: true}} = socket),
    do: {:noreply, socket |> assign_room() |> track_multiplayer()}

  @impl true
  # Handle event for single player game
  def handle_event("play", _params, socket), do: {:noreply, assign(socket, action: :play)}

  @impl true
  def handle_event("multiplayer-to-singleplayer", _params, socket) do
    BattleshipWeb.Endpoint.unsubscribe(socket.assigns.room_id)
    Presence.untrack(self(), socket.assigns.room_id, socket.id)
    {:noreply, assign(socket, action: :play, multiplayer: false)}
  end

  @impl true
  # Originates from edit component
  def handle_info({:update_gameboard, %{gameboard: gameboard}}, socket) do
    {:noreply, assign(socket, :gameboard, gameboard)}
  end

  @impl true
  def handle_info({:update_enemy_gameboard, %{enemy_gameboard: enemy_gameboard}}, socket) do
    {:noreply, assign(socket, :enemy_gameboard, enemy_gameboard)}
  end

  @impl true
  # Originates from play component
  def handle_info({:attack_player, %{position: position}}, socket) do
    %{"row" => row, "col" => col} = position

    new_player_gameboard = Gameboard.attack(socket.assigns.gameboard, [row, col])

    socket = assign(socket, :gameboard, new_player_gameboard)

    if Gameboard.has_won?(new_player_gameboard) do
      {:noreply, socket |> assign(:game_over, true) |> assign(:winner, "computer")}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(
        {:attack_enemy, %{position: position}},
        %{assigns: %{multiplayer: false}} = socket
      ) do
    %{"row" => row, "col" => col} = position

    new_enemy_board =
      Gameboard.attack(socket.assigns.enemy_gameboard, [
        String.to_integer(row),
        String.to_integer(col)
      ])

    socket = assign(socket, :enemy_gameboard, new_enemy_board)

    if Gameboard.has_won?(new_enemy_board) do
      {:noreply, socket |> assign(:game_over, true) |> assign(:winner, "player")}
    else
      {:noreply, socket}
    end
  end

  @impl true
  # Originates from multiplyaer play component
  def handle_info(
        {:attack_enemy, %{position: position}},
        %{assigns: %{multiplayer: true}} = socket
      ) do
    %{"row" => row, "col" => col} = position

    new_enemy_board =
      Gameboard.attack(socket.assigns.enemy_gameboard, [
        String.to_integer(row),
        String.to_integer(col)
      ])

    socket =
      socket |> assign(:enemy_gameboard, new_enemy_board) |> assign(:edit_enemy_board, false)

    if Gameboard.has_won?(new_enemy_board) do
      Phoenix.PubSub.broadcast_from(Battleship.PubSub, self(), socket.assigns.room_id, %{
        event: "multiplayer:win"
      })

      {:noreply, socket |> assign(:game_over, true) |> assign(:win, true)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  # Tracks the number of player online
  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}, topic: "player"},
        %{assigns: %{player_count: count}} = socket
      ) do
    count = count + map_size(joins) - map_size(leaves)
    {:noreply, assign(socket, :player_count, count)}
  end

  @impl true
  # Tracks the number of players in a particular room
  def handle_info(
        %{event: "presence_diff", payload: %{joins: _joins, leaves: leaves}, topic: room_id},
        socket
      ) do
    count = Presence.list(room_id) |> map_size()

    if count == 2 do
      # a "handshake" step where players send their board data to each other
      Phoenix.PubSub.broadcast_from(Battleship.PubSub, self(), room_id, %{
        event: "multiplayer:handshake",
        from: self(),
        gameboard: socket.assigns.gameboard
      })

      {:noreply, socket}
    else
      left = map_size(leaves)

      if left != 0 do
        # A player left the game
        {:noreply, assign(socket, player_left: true, edit_enemy_board: false)}
      else
        # send user to a "waiting room"
        {:noreply, assign(socket, action: :waiting)}
      end
    end
  end

  def handle_info(%{event: "multiplayer:handshake", gameboard: enemy_gameboard}, socket) do
    {:noreply, socket |> assign(:action, :play) |> assign(:enemy_gameboard, enemy_gameboard)}
  end

  def handle_info(%{event: "multiplayer:win"}, socket) do
    {:noreply,
     socket |> assign(:edit_enemy_board, false) |> assign(:game_over, true) |> assign(:win, false)}
  end

  def handle_info(
        %{event: "attack_player", position: %{"row" => row, "col" => col}} = _payload,
        socket
      ) do
    new_board =
      Gameboard.attack(socket.assigns.gameboard, [String.to_integer(row), String.to_integer(col)])

    {:noreply, socket |> assign(:gameboard, new_board) |> assign(:edit_enemy_board, true)}
  end

  defp track_player_count(socket) do
    count = Presence.list(@player_count_topic) |> map_size()

    if connected?(socket) do
      BattleshipWeb.Endpoint.subscribe(@player_count_topic)
      Presence.track(self(), @player_count_topic, socket.id, %{id: socket.id})
    end

    assign(socket, :player_count, count)
  end

  defp assign_room(socket) do
    case Room.get_room() do
      {:new_room, room_id} ->
        # `edit_enemy_board: true` -> Give first chance to the player who joined a newly created room
        socket |> assign(:room_id, room_id) |> assign(:edit_enemy_board, true)

      {:existing_room, room_id} ->
        if player_present?(room_id) do
          # `edit_enemy_board: false` -> Give second chance to the player who joined an existing room
          socket |> assign(:room_id, room_id) |> assign(:edit_enemy_board, false)
        else
          assign_room(socket)
        end
    end
  end

  defp track_multiplayer(socket) do
    topic = socket.assigns.room_id
    BattleshipWeb.Endpoint.subscribe(topic)
    Presence.track(self(), topic, socket.id, %{room_id: topic})
    socket
  end

  defp player_present?(room_id) do
    # Checks if a room has players or not
    player_count = Presence.list(room_id) |> map_size()
    player_count > 0
  end
end
