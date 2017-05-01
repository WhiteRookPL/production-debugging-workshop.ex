defmodule KV.RestAPI.Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :kv_rest_api

  plug Plug.Static,
    at: "/", from: :kv_rest_api, gzip: false,
    only: ~w(robots.txt)

  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug KV.RestAPI.Web.Router
end
