defmodule KV.RestAPI.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(KV.RestAPI.Web.Endpoint, []),
      worker(KV.RestAPI.Command.Server, [ KV.RestAPI.Command.Server ])
    ]

    opts = [strategy: :one_for_one, name: KV.RestAPI.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
