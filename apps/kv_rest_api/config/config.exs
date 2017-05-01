use Mix.Config

config :kv_rest_api,
  namespace: KV.RestAPI

config :kv_rest_api, KV.RestAPI.Web.Endpoint,
  url: [
    host: "localhost"
  ],
  secret_key_base: "OuchMySecretKeyBaseLeaked",
  render_errors: [
    view: KV.RestAPI.Web.ErrorView,
    accepts: ~w(json)
  ],
  pubsub: [
    name: KV.RestAPI.PubSub,
    adapter: Phoenix.PubSub.PG2
  ]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [
    :request_id
  ]

import_config "#{Mix.env}.exs"
