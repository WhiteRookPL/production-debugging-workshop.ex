use Mix.Config

config :phoenix, :serve_endpoints, true

config :kv_rest_api, KV.RestAPI.Web.Endpoint,
  http: [ port: 8080 ],
  url: [
    port: 8080
  ],
  server: true,
  secret_key_base: "DontTryThisAtHomeAndWork"

config :logger, level: :info