# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :data_transformer_api,
       ecto_repos: [DataTransformerApi.Repo]

config :data_transformer_api, DataTransformerApi.Repo,
  database: "csum_gs_db",
  username: "postgres",
  password: "kallah",
  hostname: "localhost"

config :data_transformer_api,
  generators: [binary_id: true]

# Configures the endpoint
config :data_transformer_api, DataTransformerApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "iKn2PVuEAdmkjeZbw8cDnZFNMMIIKiDXNMlkW9Te0imy/Wdj1Ke9HMOUf0YOXa7G",
  render_errors: [view: DataTransformerApiWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: DataTransformerApi.PubSub,
  live_view: [signing_salt: "Rd9pfGd1"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
