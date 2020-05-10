# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :haproxy_playground,
  ecto_repos: [HaproxyPlayground.Repo]

# Configures the endpoint
config :haproxy_playground, HaproxyPlaygroundWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "HTIkU2mJHwK4RQIL41jaPrILOK6FTDrZG1qjJclhQ1vbSzJ//g6V5/VqLLtIxnho",
  render_errors: [view: HaproxyPlaygroundWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: HaproxyPlayground.PubSub,
  live_view: [signing_salt: "QxuY/QDF"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason
config :tesla, adapter: Tesla.Adapter.Mint

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
