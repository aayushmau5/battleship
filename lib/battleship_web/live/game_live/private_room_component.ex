defmodule BattleshipWeb.GameLive.PrivateRoomComponent do
  use BattleshipWeb, :live_component

  alias Battleship.Room
  alias BattleshipWeb.Presence

  @impl true
  def mount(socket) do
    {
      :ok,
      assign(socket, error: nil, room_id: "")
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="animate-fade-in" id="#private-room-component">
      <h1 class="text-center">Play with another player</h1>
      <button phx-click="generate-room-id" phx-target={@myself} class="text-white my-3 p-2 rounded bg-teal-600 hover:bg-teal-500 font-bold transition-all ease-linear block mx-auto">Generate Room ID</button>

      <%= if @room_id != "" do %>
        <p class="text-center">Room ID: <span id="room-id-value" class="text-sm break-all"><%= @room_id %></span></p>
        <button id="copy-button" class="font-bold cursor-pointer bg-none outline-none block mx-auto mb-3" phx-hook="CopyToClipboard">Copy</button>
      <% end %>

      <p class="font-bold text-xl text-center">OR</p>

      <div class="mx-auto mb-3">
        <p class="text-center my-3">Already have a Room ID?</p>

        <%= if @error do %>
          <p class="text-center mb-3 text-red-400"><%= @error %></p>
        <% end %>

        <form phx-target={@myself} phx-submit="private-room-join">
          <input id="room-id" phx-value="room-id" name="room-id" required class="text-white block mx-auto border border-gray-300 p-2 bg-transparent rounded-md outline-none" value={@room_id} />
          <button type="submit" class="text-white mt-3 p-2 rounded bg-teal-600 hover:bg-teal-500 font-bold transition-all ease-linear block mx-auto">Join Room</button>
        </form>
      </div>
      <.btn click="index" to="#home-component" class="mt-6 text-white p-2 rounded bg-teal-600 hover:bg-teal-500 font-bold transition-all ease-linear block mx-auto">Back</.btn>
    </div>
    """
  end

  @impl true
  def handle_event("generate-room-id", _params, socket) do
    {:noreply, assign(socket, room_id: Room.generate_room_id())}
  end

  @impl true
  def handle_event("private-room-join", params, socket) do
    room_id = params["room-id"]

    if Room.valid_room_id?(room_id) do
      player_count = Presence.list(room_id) |> map_size()

      case player_count do
        0 ->
          send(self(), {:private_room, room_id})
          {:noreply, socket}

        2 ->
          {:noreply, assign(socket, error: "Room full", room_id: room_id)}

        _ ->
          send_check_message(room_id)
          {:noreply, socket}
      end
    else
      {:noreply, assign(socket, error: "Invalid Room ID", room_id: room_id)}
    end
  end

  defp send_check_message(topic) do
    Phoenix.PubSub.subscribe(Battleship.PubSub, topic)

    Phoenix.PubSub.broadcast_from(Battleship.PubSub, self(), topic, %{
      event: "availability-check",
      from: self(),
      topic: topic
    })
  end
end
