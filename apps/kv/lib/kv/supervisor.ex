defmodule KV.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(KV.Registry, [ KV.Registry ]),
      supervisor(KV.Bucket.Supervisor, []),
      supervisor(Task.Supervisor, [ [ name: KV.RouterTasks ] ]),
      worker(KV.GarbageCollector, [ KV.GarbageCollector ]),
    ]

    supervise(children, strategy: :rest_for_one)
  end
end