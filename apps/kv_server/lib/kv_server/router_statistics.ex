defmodule KV.Router.Statistics do
  use GenServer
  require Logger

  @doc """
  """
  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  @doc """
  """
  def collect(name, {left, right, bucket}) do
    GenServer.call(name, {:collect, left, right, bucket})
  end

  # Private API.

  def init(:ok) do
    characters = :ets.new(KV.Router.Statistics.Characters.Stats, [:named_table, write_concurrency: true])
    rests = :ets.new(KV.Router.Statistics.Rests.Stats, [:named_table, write_concurrency: true])
    buckets = :ets.new(KV.Router.Statistics.Buckets.Stats, [:named_table, write_concurrency: true])

    restore(Application.get_env(:kv_server, :persistence_enabled))

    {:ok, {characters, rests, buckets}}
  end

  def handle_call({:collect, left, right, bucket}, _from, {characters, rests, buckets}) do
    :ets.update_counter(characters, left, {2, 1}, {left, 0})
    :ets.update_counter(rests, right, {2, 1}, {right, 0})
    :ets.update_counter(buckets, bucket, {2, 1}, {buckets, 0})

    {:reply, :collected, {characters, rests, buckets}}
  end

  # Private API

  defp restore(false), do: :ok
  defp restore(true) do
    {:ok, commands} = KV.Persistence.restore()

    Enum.each(commands, fn(command) ->
      {:ok, parsed } = KV.Server.Command.parse(command)

      KV.Router.route(elem(parsed, 1), KV.Server.Command, :execute, [ parsed ])
    end)

    Logger.info "Restored #{length(commands)} commands from DB."
  end
end