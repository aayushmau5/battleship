defmodule BattleshipWeb.GameLive.Index do
  use BattleshipWeb, :live_view

  alias Battleship.{Gameboard, Room, Player, Computer, Player.Name, TaskRunner}
  alias BattleshipWeb.Presence

  @player_count_topic "player-join"

  @type action() ::
          :index | :multiplayer_choice | :edit | :howto | :private_room | :waiting | :play
  @type game() :: :singleplayer | :multiplayer | :private

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       action: :index,
       game: :singleplayer,
       player: Player.new(Name.generate()),
       opponent: %Player{},
       game_over: false,
       player_left: false
     )
     |> track_player_count()}
  end

  @impl true
  def handle_event("index", _params, socket) do
    if socket.assigns.game != :singleplayer && socket.assigns.player.room_id,
      do: unsubscribe_player(socket)

    # Reset player state
    {:noreply,
     assign(socket,
       action: :index,
       game: :singleplayer,
       player: Player.reset_state(socket.assigns.player),
       opponent: %Player{},
       game_over: false,
       player_left: false
     )}
  end

  @impl true
  def handle_event("play-again", _params, %{assigns: %{game: :multiplayer}} = socket) do
    unsubscribe_player(socket)

    player = Player.reset_state(socket.assigns.player)

    {:noreply,
     assign(socket, action: :edit, player: player, game_over: false, player_left: false)}
  end

  @impl true
  def handle_event("play-again", _params, %{assigns: %{game: :private}} = socket) do
    unsubscribe_player(socket)

    player =
      socket.assigns.player
      |> Player.update_player_chance(false)
      |> Player.set_win(false)
      |> Player.update_player_status(false)

    {:noreply,
     assign(socket, action: :edit, player: player, game_over: false, player_left: false)}
  end

  @impl true
  def handle_event("play-again", _params, socket),
    do: {:noreply, assign(socket, action: :edit, game_over: false)}

  @impl true
  def handle_event("howto", _params, socket),
    do: {:noreply, assign(socket, action: :howto)}

  @impl true
  def handle_event("singleplayer", _params, socket),
    do: {:noreply, assign(socket, action: :edit)}

  @impl true
  def handle_event("private-room", _params, socket),
    do: {:noreply, assign(socket, action: :private_room)}

  @impl true
  def handle_event("multiplayer-choice", _params, socket),
    do: {:noreply, assign(socket, action: :multiplayer_choice)}

  @impl true
  def handle_event("multiplayer", _params, socket),
    do: {:noreply, assign(socket, game: :multiplayer, action: :edit)}

  @impl true
  def handle_event("play", _params, %{assigns: %{game: :multiplayer}} = socket),
    do: {:noreply, socket |> assign_room() |> track_multiplayer()}

  @impl true
  def handle_event("play", _params, %{assigns: %{game: :private}} = socket),
    do: {:noreply, socket |> track_multiplayer()}

  @impl true
  # Handle event for single player game
  def handle_event("play", _params, socket), do: {:noreply, assign(socket, action: :play)}

  @impl true
  def handle_event("multiplayer-to-singleplayer", _params, socket) do
    room_id = socket.assigns.player.room_id
    BattleshipWeb.Endpoint.unsubscribe(room_id)
    Presence.untrack(self(), room_id, socket.id)
    {:noreply, assign(socket, action: :play, game: :singleplayer)}
  end

  @impl true
  def handle_info({:change_player_name, player_name}, socket) do
    player = Player.update_player_name(socket.assigns.player, player_name)
    {:noreply, assign(socket, player: player)}
  end

  @impl true
  def handle_info({:private_room, room_id}, socket) do
    player = Player.update_room_id(socket.assigns.player, room_id)
    {:noreply, assign(socket, game: :private, action: :edit, player: player)}
  end

  @impl true
  # Originates from edit component
  def handle_info({:update_player_gameboard, %{gameboard: gameboard}}, socket) do
    {:noreply,
     assign(socket, player: Player.update_player_gameboard(socket.assigns.player, gameboard))}
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
        %{assigns: %{game: :singleplayer}} = socket
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
  def handle_info(
        {:attack_opponent, %{position: position}},
        socket
      ) do
    %{"row" => row, "col" => col} = position

    new_opponent_board =
      Gameboard.attack(socket.assigns.opponent.gameboard, [
        String.to_integer(row),
        String.to_integer(col)
      ])

    player = Player.update_player_chance(socket.assigns.player, false)
    opponent = Player.update_player_gameboard(socket.assigns.opponent, new_opponent_board)

    socket = assign(socket, player: player, opponent: opponent)

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
        %{
          event: "presence_diff",
          payload: %{leaves: leaves},
          topic: room_id
        },
        socket
      ) do
    count = Presence.list(room_id) |> map_size()

    if count == 2 do
      # a "handshake" step where players send their data to each other
      player = Player.update_player_status(socket.assigns.player, true)

      Phoenix.PubSub.broadcast_from(Battleship.PubSub, self(), room_id, %{
        event: "multiplayer:handshake",
        from: self(),
        opponent: socket.assigns.player
      })

      {:noreply, assign(socket, player: player)}
    else
      left = map_size(leaves)

      if left != 0 do
        player = Player.update_player_chance(socket.assigns.player, false)
        # A player left the game
        {:noreply, assign(socket, game_over: true, player_left: true, player: player)}
      else
        # Give first chance to user who are waiting
        player = Player.update_player_chance(socket.assigns.player, true)
        # send user to a "waiting room"
        {:noreply, assign(socket, action: :waiting, player: player)}
      end
    end
  end

  def handle_info(%{event: "multiplayer:handshake", opponent: opponent}, socket) do
    {:noreply, assign(socket, action: :play, opponent: opponent)}
  end

  def handle_info(%{event: "multiplayer:win"}, socket) do
    player = Player.update_player_chance(socket.assigns.player, false)
    {:noreply, socket |> assign(:player, player) |> assign(:game_over, true)}
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

    player =
      socket.assigns.player
      |> Player.update_player_gameboard(new_player_board)
      |> Player.update_player_chance(true)

    {:noreply, socket |> assign(:player, player)}
  end

  def handle_info(%{event: "availability-check", topic: topic}, socket) do
    Phoenix.PubSub.broadcast_from(Battleship.PubSub, self(), topic, %{
      event: "availability",
      from: self(),
      available: !socket.assigns.player.in_game,
      topic: topic
    })

    {:noreply, socket}
  end

  def handle_info(%{event: "availability", available: true, topic: topic}, socket) do
    BattleshipWeb.Endpoint.unsubscribe(topic)

    send_update(self(), BattleshipWeb.GameLive.PrivateRoomComponent,
      id: "private-room-component",
      error: nil
    )

    send(self(), {:private_room, topic})

    {:noreply, socket}
  end

  def handle_info(%{event: "availability", available: false, topic: topic}, socket) do
    send_update(self(), BattleshipWeb.GameLive.PrivateRoomComponent,
      id: "private-room-component",
      error: "Ongoing game",
      room_id: topic
    )

    BattleshipWeb.Endpoint.unsubscribe(topic)

    {:noreply, socket}
  end

  defp assign_room(socket) do
    case Room.get_room() do
      {:new_room, room_id} ->
        player = Player.update_room_id(socket.assigns.player, room_id)

        socket |> assign(:player, player)

      {:existing_room, room_id} ->
        if player_present?(room_id) do
          player = Player.update_room_id(socket.assigns.player, room_id)

          socket |> assign(:player, player)
        else
          # Get another room
          assign_room(socket)
        end
    end
  end

  defp track_multiplayer(socket) do
    topic = socket.assigns.player.room_id

    count = Presence.list(topic) |> map_size()

    if count == 2 do
      # when 2 players are already in a "room", and another player tries to join
      socket = assign(socket, action: :private_room)

      send_update(self(), BattleshipWeb.GameLive.PrivateRoomComponent,
        id: "private-room-component",
        error: "Ongoing game",
        room_id: nil
      )

      socket
    else
      BattleshipWeb.Endpoint.subscribe(topic)
      Presence.track(self(), topic, socket.id, %{room_id: topic})
      socket
    end
  end

  defp track_player_count(socket) do
    count = Presence.list(@player_count_topic) |> map_size()

    if connected?(socket) do
      BattleshipWeb.Endpoint.subscribe(@player_count_topic)
      Presence.track(self(), @player_count_topic, socket.id, %{id: socket.id})
    end

    remote_node = TaskRunner.get_task_runner_node()

    if remote_node != nil do
      # Execute function on remote node
      # This task updates the page view count
      TaskRunner.run(
        %{module: Accumulator.Tasks, function: :update_battleship_view_count, args: []},
        remote_node
      )
    end

    assign(socket, player_count: count)
  end

  # Checks if a room has players or not
  defp player_present?(room_id) do
    player_count = Presence.list(room_id) |> map_size()
    player_count > 0
  end

  defp unsubscribe_player(socket) do
    room_id = socket.assigns.player.room_id
    BattleshipWeb.Endpoint.unsubscribe(room_id)
    Presence.untrack(self(), room_id, socket.id)
  end
end
