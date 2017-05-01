defmodule KV.RestAPI.Web.DebugController do
  use KV.RestAPI.Web, :controller

  def history(conn, _params) do
    with commands = KV.RestAPI.Command.Server.history() do
      conn
      |> put_status(:ok)
      |> json(commands)
    end
  end
end
