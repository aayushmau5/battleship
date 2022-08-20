defmodule BattleshipWeb.GameLive.Index do
  use BattleshipWeb, :live_view

  alias Battleship.Gameboard
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
       winner: nil
     )
     |> track_player_count()}
  end

  @impl true
  def handle_event("index", _params, socket) do
    {:noreply,
     socket
     |> assign(:action, :index)
     |> assign(:gameboard, Gameboard.generate_board())}
  end

  @impl true
  def handle_event("edit", _params, socket) do
    {:noreply, socket |> assign(:action, :edit)}
  end

  @impl true
  def handle_event("play", _params, socket) do
    {:noreply, socket |> assign(:action, :play)}
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
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
        %{assigns: %{player_count: count}} = socket
      ) do
    count = count + map_size(joins) - map_size(leaves)
    {:noreply, assign(socket, :player_count, count)}
  end

  defp track_player_count(socket) do
    count = Presence.list(@player_count_topic) |> map_size()

    if connected?(socket) do
      BattleshipWeb.Endpoint.subscribe(@player_count_topic)
      Presence.track(self(), @player_count_topic, socket.id, %{id: socket.id})
    end

    assign(socket, :player_count, count)
  end
end
