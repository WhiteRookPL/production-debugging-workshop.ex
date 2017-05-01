defmodule KV.Persistence do
  @env Mix.env
  @app Mix.Project.config[:app]

  @compile {:autoload, false}
  @on_load :init

  @doc """
  Initializing the NIF module (used by `on_load` callback).
  """
  def init() do
    path = Application.app_dir(@app, ["priv", to_string(@env), "kv_persistence"])
    :ok = :erlang.load_nif(path, 0)
  end

  # Public API.

  @doc """
  Storing single `command` provided in tuple form inside events source.
  """
  def store(command)

  def store({:create, bucket}) do
    line = "CREATE #{bucket}"
    persist_command(line)
  end

  def store({:delete, bucket}) do
    line = "DELETE #{bucket}"
    persist_command(line)
  end

  def store({:put, bucket, key, value}) do
    line = "PUT #{bucket} #{key} #{value}"
    persist_command(line)
  end

  def store({:delete, bucket, key}) do
    line = "DELETE #{bucket} #{key}"
    persist_command(line)
  end

  def store({:sum, bucket}) do
    line = "SUM #{bucket}"
    persist_command(line)
  end

  def store({:avg, bucket}) do
    line = "AVG #{bucket}"
    persist_command(line)
  end

  def store({:word_count, bucket, key}) do
    line = "WORDCOUNT #{bucket} #{key}"
    persist_command(line)
  end

  def store(_command) do
    {:error, :not_stored}
  end

  @doc """
  Restoring commands from events source, provided as list of stringified commands.
  """
  def restore() do
    {:ok, lines} = restore_commands()

    result = lines |> Enum.map(&to_string/1)
    {:ok, result}
  end

  @doc """
  Function for clearing events source.
  """
  def clear_persistence() do
    raise "NIF clear_persistence/0 not implemented"
  end

  defp persist_command(_line) do
    raise "NIF persist_command/1 not implemented"
  end

  defp restore_commands() do
    raise "NIF restore_commands/0 not implemented"
  end
end
