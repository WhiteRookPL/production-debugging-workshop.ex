use Mix.Config

config :kv_rest_api, KV.RestAPI.Web.Endpoint,
  http: [
    port: 8080
  ],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20
