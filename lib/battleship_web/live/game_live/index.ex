defmodule BattleshipWeb.GameLive.Index do
  use BattleshipWeb, :live_view

  alias Battleship.{Gameboard, Room, Player, Computer}
  alias BattleshipWeb.Presence

  @player_count_topic "player-join"

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       action: :index,
       multiplayer: false,
       player: Player.new(),
       opponent: %Player{},
       game_over: false,
       player_left: false
     )
     |> track_player_count()}
  end

  @impl true
  def handle_event("index", _params, socket) do
    if socket.assigns.multiplayer && socket.assigns.player.room_id do
      room_id = socket.assigns.player.room_id
      BattleshipWeb.Endpoint.unsubscribe(room_id)
      Presence.untrack(self(), room_id, socket.id)
    end

    # Reset player state
    {:noreply,
     assign(socket,
       action: :index,
       multiplayer: false,
       player: Player.reset_state(socket.assigns.player),
       opponent: %Player{},
       game_over: false,
       player_left: false
     )}
  end

  @impl true
  def handle_event("howto", _params, socket),
    do: {:noreply, assign(socket, action: :howto)}

  @impl true
  def handle_event("singleplayer", _params, socket),
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
  def handle_info({:update_player_gameboard, %{gameboard: gameboard}}, socket) do
    player = Player.update_player_gameboard(socket.assigns.player, gameboard)
    {:noreply, assign(socket, player: player)}
  end

  @impl true
  def handle_info(:set_computer_opponent, socket) do
    opponent =
      Player.new("Computer")
      |> Player.update_player_gameboard(Computer.generate_computer_gameboard())

    {:noreply, assign(socket, opponent: opponent)}
  end

  @impl true
  # Originates from play component when a computer attacks player
  def handle_info({:attack_player, %{position: position}}, socket) do
    %{"row" => row, "col" => col} = position

    new_player_gameboard = Gameboard.attack(socket.assigns.player.gameboard, [row, col])
    player = Player.update_player_gameboard(socket.assigns.player, new_player_gameboard)

    socket = assign(socket, player: player)

    if Gameboard.has_won?(new_player_gameboard) do
      opponent = Player.set_win(socket.assigns.opponent, true)
      {:noreply, socket |> assign(:game_over, true) |> assign(:opponent, opponent)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(
        {:attack_opponent, %{position: position}},
        %{assigns: %{multiplayer: false}} = socket
      ) do
    %{"row" => row, "col" => col} = position

    new_opponent_board =
      Gameboard.attack(socket.assigns.opponent.gameboard, [
        String.to_integer(row),
        String.to_integer(col)
      ])

    opponent = Player.update_player_gameboard(socket.assigns.opponent, new_opponent_board)

    socket = assign(socket, :opponent, opponent)

    if Gameboard.has_won?(new_opponent_board) do
      player = Player.set_win(socket.assigns.player, true)
      {:noreply, socket |> assign(:game_over, true) |> assign(:player, player)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  # Originates from multiplyaer play component
  def handle_info(
        {:attack_opponent, %{position: position}},
        %{assigns: %{multiplayer: true}} = socket
      ) do
    %{"row" => row, "col" => col} = position

    new_opponent_board =
      Gameboard.attack(socket.assigns.opponent.gameboard, [
        String.to_integer(row),
        String.to_integer(col)
      ])

    opponent = Player.update_player_gameboard(socket.assigns.opponent, new_opponent_board)

    socket = assign(socket, opponent: opponent, enable_attack: false)

    if Gameboard.has_won?(new_opponent_board) do
      player = Player.set_win(socket.assigns.player, true)

      Phoenix.PubSub.broadcast_from(Battleship.PubSub, self(), socket.assigns.player.room_id, %{
        event: "multiplayer:win"
      })

      {:noreply, socket |> assign(:game_over, true) |> assign(:player, player)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  # Tracks the number of player online
  def handle_info(
        %{
          event: "presence_diff",
          payload: %{joins: joins, leaves: leaves},
          topic: @player_count_topic
        },
        %{assigns: %{player_count: count}} = socket
      ) do
    count = count + map_size(joins) - map_size(leaves)
    {:noreply, assign(socket, :player_count, count)}
  end

  @impl true
  # Tracks the number of players in a particular room
  def handle_info(
        %{event: "presence_diff", payload: %{leaves: leaves}, topic: room_id},
        socket
      ) do
    count = Presence.list(room_id) |> map_size()

    if count == 2 do
      # a "handshake" step where players send their data to each other
      Phoenix.PubSub.broadcast_from(Battleship.PubSub, self(), room_id, %{
        event: "multiplayer:handshake",
        from: self(),
        opponent: socket.assigns.player
      })

      {:noreply, socket}
    else
      left = map_size(leaves)

      if left != 0 do
        # A player left the game
        {:noreply, assign(socket, game_over: true, player_left: true, enable_attack: false)}
      else
        # send user to a "waiting room"
        {:noreply, assign(socket, action: :waiting)}
      end
    end
  end

  def handle_info(%{event: "multiplayer:handshake", opponent: opponent}, socket) do
    {:noreply, assign(socket, action: :play, opponent: opponent)}
  end

  def handle_info(%{event: "multiplayer:win"}, socket) do
    {:noreply, socket |> assign(:enable_attack, false) |> assign(:game_over, true)}
  end

  def handle_info(
        %{event: "attack_player", position: %{"row" => row, "col" => col}} = _payload,
        socket
      ) do
    new_player_board =
      Gameboard.attack(socket.assigns.player.gameboard, [
        String.to_integer(row),
        String.to_integer(col)
      ])

    player = Player.update_player_gameboard(socket.assigns.player, new_player_board)

    {:noreply, socket |> assign(:player, player) |> assign(:enable_attack, true)}
  end

  defp assign_room(socket) do
    case Room.get_room() do
      {:new_room, room_id} ->
        player = Player.update_room_id(socket.assigns.player, room_id)

        # `enable_attack: true` -> Give first chance to the player who joined a newly created room
        socket |> assign(:player, player) |> assign(:enable_attack, true)

      {:existing_room, room_id} ->
        if player_present?(room_id) do
          player = Player.update_room_id(socket.assigns.player, room_id)

          # `edit_opponent_board: false` -> Give second chance to the player who joined an existing room
          socket |> assign(:player, player) |> assign(:enable_attack, false)
        else
          # Get another room
          assign_room(socket)
        end
    end
  end

  defp track_multiplayer(socket) do
    topic = socket.assigns.player.room_id
    BattleshipWeb.Endpoint.subscribe(topic)
    Presence.track(self(), topic, socket.id, %{room_id: topic})
    socket
  end

  defp track_player_count(socket) do
    count = Presence.list(@player_count_topic) |> map_size()

    if connected?(socket) do
      BattleshipWeb.Endpoint.subscribe(@player_count_topic)
      Presence.track(self(), @player_count_topic, socket.id, %{id: socket.id})
    end

    assign(socket, player_count: count)
  end

  # Checks if a room has players or not
  defp player_present?(room_id) do
    player_count = Presence.list(room_id) |> map_size()
    player_count > 0
  end
end
