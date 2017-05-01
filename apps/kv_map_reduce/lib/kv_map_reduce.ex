defmodule KV.MapReduce do
  use Application

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(KV.MapReduce.Scheduler, [ KV.MapReduce.Scheduler ])
    ]

    opts = [strategy: :one_for_one, name: KV.MapReduce.Supervisor]
    Supervisor.start_link(children, opts)
  end
end