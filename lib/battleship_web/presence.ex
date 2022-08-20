defmodule BattleshipWeb.Presence do
  use Phoenix.Presence, otp_app: :battleship, pubsub_server: Battleship.PubSub
end
