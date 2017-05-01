defmodule KV.RestAPI.Web.Client do
  # Public API.

  @doc """
  Client operation responsible for listing all buckets.
  """
  def buckets() do
    response = command("BUCKETS") |> String.split("\r\n")

    case response do
      [ "OK" ] -> []
      [ buckets | _tail ] -> String.split(buckets, ",")
    end
  end

  @doc """
  Client operation responsible for creating new `bucket`.
  """
  def create(bucket) do
    case command("CREATE #{bucket}") do
      "OK" -> :ok
      _ -> :error
    end
  end

  @doc """
  Client operation responsible for creating new `key` in the `bucket` with provided `value`.
  """
  def create(bucket, key, value) do
    case command(["PUT #{bucket} #{key} " | Base.encode64(to_string(value))]) do
      "OK" -> :ok
      _ -> :error
    end
  end

  @doc """
  Client operation responsible for creating new `key` in the `bucket` with provided `value` and ttl.
  """
  def create(bucket, key, value, ttl) do
    case command(["PUTX #{bucket} #{key} ", Base.encode64(to_string(value)), " #{ttl}"]) do
      "OK" -> :ok
      _ -> :error
    end
  end

  @doc """
  Client operation responsible for getting value for `key` in `bucket`.
  If `key` does not exist in the `bucket` returns `nil` as a value.
  """
  def get(bucket, key) do
    response = command("GET #{bucket} #{key}") |> String.split("\r\n")

    case response do
      [ "OK" ] -> nil
      [ value | _tail ] -> value
    end
  end

  @doc """
  Client operation responsible for deleting a `bucket`.
  """
  def delete(bucket) do
    case command("DELETE #{bucket}") do
      "OK" -> :ok
      "NOT_FOUND" -> :not_found
    end
  end

  @doc """
  Client operation responsible for deleting a `key` in `bucket`.
  """
  def delete(bucket, key) do
    case command("DELETE #{bucket} #{key}") do
      "OK" -> :ok
      _ -> :error
    end
  end

  @doc """
  Client operation responsible for listing keys in `bucket`.
  """
  def keys(bucket) do
    response = command("KEYS #{bucket}") |> String.split("\r\n")

    case response do
      [ "OK" ] -> []
      [ keys | _tail ] -> String.split(keys, ",")
    end
  end

  @doc """
  Client operation responsible for calculating average for a `bucket`.
  """
  def avg(bucket) do
    [ id | _tail ] =
      command("AVG #{bucket}")
      |> String.split("\r\n")

    id
  end

  @doc """
  Client operation responsible for calculating sum for a `bucket`.
  """
  def sum(bucket) do
    [ id | _tail ] =
      command("SUM #{bucket}")
      |> String.split("\r\n")

    id
  end

  @doc """
  Client operation responsible for calculating word count for a `key` in the `bucket`.
  """
  def word_count(bucket, key) do
    [ id | _tail ] =
      command("WORDCOUNT #{bucket} #{key}")
      |> String.split("\r\n")

    case id do
      "NOT_FOUND" -> :not_found
      _           -> id
    end
  end

  @doc """
  Client operation responsible for getting result of aggregation job identified by `id`.
  """
  def result(id) do
    response = command("RESULT #{id}") |> String.split("\r\n")

    case response do
      [ "JOB NOT FOUND" ] -> :not_found
      [ "INVALID JOB ID"] -> :error
      [ result | _tail ]  -> result
    end
  end

  # Private API.

  defp kv_server_open() do
    {:ok, socket} = :gen_tcp.connect('127.0.0.1', 4040, [:binary, active: false])
    socket
  end

  defp kv_server_send(socket, what) do
    :gen_tcp.send(socket, what)
  end

  defp kv_server_recv(socket) do
    {:ok, message} = :gen_tcp.recv(socket, 0)
    message
  end

  defp command(command) do
    socket = kv_server_open()

    kv_server_send(socket, [command, ?\r, ?\n])

    String.trim(kv_server_recv(socket))
  end
end
