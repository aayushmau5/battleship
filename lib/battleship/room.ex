defmodule Battleship.Room do
  @moduledoc """
  This module is responsible for storing and retrieving room ids.

  It uses `Agent` to store and retrieve ids.
  These ids are stored in a list.

  - what if the current player leaves before game start(or when playing game)?
  - what if the opponent player leaves before game start(or when playing game)?
  """
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> [] end, name: :rooms_state)
  end

  @doc """
  Gets a room id from the list.
  """
  def get_room() do
    Agent.get_and_update(:rooms_state, fn list ->
      case list do
        [] ->
          room_id = generate_room_id()
          {{:new_room, room_id}, [room_id]}

        [first | list] ->
          {{:existing_room, first}, list}
      end
    end)
  end

  @doc """
  Deletes a particular id from the list of room ids.
  """
  def delete_room(id) do
    Agent.update(:rooms_state, fn list ->
      List.delete(list, id)
    end)
  end

  def generate_room_id, do: UUID.uuid4(:hex)

  def valid_room_id?(room_id) do
    case UUID.info(room_id) do
      {:ok, _} -> true
      {:error, _message} -> false
    end
  end
end
