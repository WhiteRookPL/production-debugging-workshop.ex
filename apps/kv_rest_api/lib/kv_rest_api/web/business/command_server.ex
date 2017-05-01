defmodule KV.RestAPI.Command.Server do
  use GenServer

  ## Client API

  @doc """
  Starts the command server with the given `name`.
  """
  def start_link(name) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  @doc """
  Executes the command.
  """
  def execute(command, args) do
    GenServer.call(KV.RestAPI.Command.Server, {:command, command, args})
  end

  @doc """
  Returns the history of executed commands.
  """
  def history() do
    GenServer.call(KV.RestAPI.Command.Server, :history)
  end

  ## Server callbacks

  def init([]) do
    {:ok, []}
  end

  def handle_call({:command, command, args}, _from, state) do
    result = apply(KV.RestAPI.Web.Client, command, args)
    {:reply, result, state ++ [ command ]}
  end

  def handle_call(:history, _from, state) do
    result = transform(state)
    {:reply, result, state}
  end

  # Private implementation.

  defp transform(commands) do
    transform(commands, [])
  end

  defp transform([], acc), do: Enum.reverse(acc)
  defp transform([ command | rest ], acc), do: transform(rest, [ "#{command}" | acc ])
end