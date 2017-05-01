defmodule KV.Bucket.Supervisor do
  use Supervisor

  # A simple module attribute that stores the supervisor name
  @name KV.Bucket.Supervisor
  @env Mix.env

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def start_bucket() do
    Supervisor.start_child(@name, [])
  end

  def init(:ok) do
    children = [
      worker(KV.Bucket, [], restart: restart_strategy(@env))
    ]

    supervise(children, strategy: :simple_one_for_one, max_restarts: 1, max_seconds: 1)
  end

  defp restart_strategy(:prod), do: :permanent
  defp restart_strategy(_), do: :transient
end
