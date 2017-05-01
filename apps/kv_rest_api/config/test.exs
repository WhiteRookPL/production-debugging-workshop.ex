use Mix.Config

config :kv_rest_api, KV.RestAPI.Web.Endpoint,
  http: [
    port: 8080
  ],
  server: false

config :logger, level: :warn
