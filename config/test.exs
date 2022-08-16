import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :battleship, BattleshipWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "5DqIofIePdR7hlrb1m31HDkJzgsPAYUBQl/18p6d/wmGLTAMEBKs5cQjQGzMOtll",
  server: false

# In test we don't send emails.
config :battleship, Battleship.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
