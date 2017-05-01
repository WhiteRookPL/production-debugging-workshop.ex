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
  def collect(name, first) do
    GenServer.call(name, {:collect, first})
  end

  # Private API.

  def init(:ok) do
    characters = :ets.new(KV.Router.Statistics.Characters.Stats, [:named_table, write_concurrency: true])

    restore(Application.get_env(:kv_server, :persistence_enabled))

    {:ok, characters}
  end

  def handle_call({:collect, first}, _from, characters) do
    :ets.update_counter(characters, first, {2, 1}, {first, 0})

    {:reply, :collected, characters}
  end

  # Private API

  defp restore(false), do: :ok
  defp restore(true) do
    start_time = System.system_time()

    {:ok, commands} = KV.Persistence.restore()

    Enum.each(commands, fn(command) ->
      {:ok, parsed } = KV.Server.Command.parse(command)

      KV.Router.route(elem(parsed, 1), KV.Server.Command, :execute_without_persistence, [ parsed ])
    end)

    end_time = System.system_time()
    Logger.info "Restored #{length(commands)} commands from DB (it took #{System.convert_time_unit(end_time - start_time, :native, :milliseconds)} ms)."
  end
end