defmodule KV.Server.Command do
  @separator ","
  @routable_commands [ :create, :del, :keys, :get, :put, :putx ]

  @doc ~S"""
  Parses the given `line` into a command.

  ## Examples

      iex> KV.Server.Command.parse "CREATE shopping\r\n"
      {:ok, {:create, "shopping"}}

      iex> KV.Server.Command.parse "DELETE shopping\r\n"
      {:ok, {:del, "shopping"}}

      iex> KV.Server.Command.parse "KEYS shopping\r\n"
      {:ok, {:keys, "shopping"}}

      iex> KV.Server.Command.parse "GET shopping milk\r\n"
      {:ok, {:get, "shopping", "milk"}}

      iex> KV.Server.Command.parse "PUT shopping milk 1\r\n"
      {:ok, {:put, "shopping", "milk", "1"}}

      iex> KV.Server.Command.parse "PUTX shopping milk 1 100\r\n"
      {:ok, {:putx, "shopping", "milk", "1", "100"}}

      iex> KV.Server.Command.parse "DELETE shopping eggs\r\n"
      {:ok, {:del, "shopping", "eggs"}}

      iex> KV.Server.Command.parse "SUM shopping\r\n"
      {:ok, {:sum, "shopping"}}

      iex> KV.Server.Command.parse "AVG shopping\r\n"
      {:ok, {:avg, "shopping"}}

      iex> KV.Server.Command.parse "WORDCOUNT shopping milk\r\n"
      {:ok, {:word_count, "shopping", "milk"}}

      iex> KV.Server.Command.parse "RESULT 1\r\n"
      {:ok, {:result, "1"}}

      iex> KV.Server.Command.parse "BUCKETS\r\n"
      {:ok, :buckets}

      iex> KV.Server.Command.parse "CREATE  shopping  \r\n"
      {:ok, {:create, "shopping"}}

  Unknown commands or commands with the wrong number of
  arguments return an error:

      iex> KV.Server.Command.parse "UNKNOWN shopping eggs\r\n"
      {:error, :unknown_command}

      iex> KV.Server.Command.parse "GET shopping\r\n"
      {:error, :unknown_command}

  """
  def parse(line) do
    case String.split(line) do
      ["CREATE", bucket] -> {:ok, {:create, encode(bucket)}}
      ["DELETE", bucket] -> {:ok, {:del, encode(bucket)}}
      ["KEYS", bucket] -> {:ok, {:keys, encode(bucket)}}
      ["GET", bucket, key] -> {:ok, {:get, encode(bucket), encode(key)}}
      ["PUT", bucket, key, value] -> {:ok, {:put, encode(bucket), encode(key), value}}
      ["PUTX", bucket, key, value, ttl] -> {:ok, {:putx, encode(bucket), encode(key), value, ttl}}
      ["DELETE", bucket, key] -> {:ok, {:del, encode(bucket), encode(key)}}
      ["SUM", bucket] -> {:ok, {:sum, encode(bucket)}}
      ["AVG", bucket] -> {:ok, {:avg, encode(bucket)}}
      ["WORDCOUNT", bucket, key] -> {:ok, {:word_count, encode(bucket), encode(key)}}
      ["RESULT", id] -> {:ok, {:result, id}}
      ["BUCKETS"] -> {:ok, :buckets}
      _ -> {:error, :unknown_command}
    end
  end

  @doc """
  Runs the given command and when needed - also routes it to proper node.
  """
  def run(command) when elem(command, 0) in @routable_commands do
    {left, right, bucket, result} = KV.Router.route(elem(command, 1), KV.Server.Command, :execute, [ command ])
    KV.Router.Statistics.collect(KV.Router.Statistics, {left, right, bucket})
    result
  end

  def run(command) do
    KV.Server.Command.execute(command)
  end

  @doc """
  Actually execute without persistence the command.
  """
  def execute_without_persistence(command) do
    invoke(command)
  end

  @doc """
  Actually executes the command.
  """
  def execute(command) do
    do_when_persistence_enabled(fn () -> KV.Persistence.store(command) end)
    invoke(command)
  end

  defp invoke({:create, bucket}) do
    KV.Registry.create(KV.Registry, bucket)
    {:ok, "OK\r\n"}
  end

  defp invoke({:del, bucket}) do
    case KV.Registry.delete(KV.Registry, bucket) do
      :bucket_deleted -> {:ok, "OK\r\n"}
      :no_such_bucket -> {:ok, "NOT_FOUND\r\n"}
    end
  end

  defp invoke({:keys, bucket}) do
    lookup bucket, fn pid ->
      stringified_keys =
        KV.Bucket.keys(pid)
        |> Enum.join(@separator)

      {:ok, "#{stringified_keys}\r\nOK\r\n"}
    end
  end

  defp invoke({:get, bucket, key}) do
    lookup bucket, fn pid ->
      value = KV.Bucket.get(pid, key)
      {:ok, "#{value}\r\nOK\r\n"}
    end
  end

  defp invoke({:put, bucket, key, value}) do
    lookup bucket, fn pid ->
      KV.Bucket.put(pid, key, Base.decode64!(value, ignore: :whitespace))
      {:ok, "OK\r\n"}
    end
  end

  defp invoke({:putx, bucket, key, value, stringified_ttl}) do
    lookup bucket, fn pid ->
      case Integer.parse(stringified_ttl, 10) do
        {ttl, _rest} ->
          KV.Bucket.putx(pid, key, Base.decode64!(value, ignore: :whitespace), ttl)
          {:ok, "OK\r\n"}

        :error ->
          {:ok, "INVALID TTL\r\n"}
      end
    end
  end

  defp invoke({:del, bucket, key}) do
    lookup bucket, fn pid ->
      KV.Bucket.delete(pid, key)
      {:ok, "OK\r\n"}
    end
  end

  defp invoke({:sum, bucket}) do
    lookup bucket, fn pid ->
      {:ok, id} = KV.MapReduce.Scheduler.new_job(KV.MapReduce.Scheduler, :sum, pid)
      {:ok, "#{id}\r\nOK\r\n"}
    end
  end

  defp invoke({:avg, bucket}) do
    lookup bucket, fn pid ->
      {:ok, id} = KV.MapReduce.Scheduler.new_job(KV.MapReduce.Scheduler, :avg, pid)
      {:ok, "#{id}\r\nOK\r\n"}
    end
  end

  defp invoke({:word_count, bucket, key}) do
    lookup bucket, fn pid ->
      id = case KV.MapReduce.Scheduler.new_word_count_job(KV.MapReduce.Scheduler, pid, key) do
        {:ok, id} -> id
        :error    -> "NOT_FOUND"
      end

      {:ok, "#{id}\r\nOK\r\n"}
    end
  end

  defp invoke({:result, stringified_id}) do
    case Integer.parse(stringified_id, 10) do
      :error ->
        {:ok, "INVALID JOB ID\r\n"}

      {id, _rest} ->
        case KV.MapReduce.Scheduler.get_job_result(KV.MapReduce.Scheduler, id) do
          :no_such_job ->
            {:ok, "JOB NOT FOUND\r\n"}

          result ->
            text = transform_to_text(result)
            {:ok, "#{text}\r\nOK\r\n"}
        end
      end
  end

  defp invoke(:buckets) do
    buckets =
      KV.Registry.buckets(KV.Registry)
      |> Enum.join(@separator)

    {:ok, "#{buckets}\r\nOK\r\n"}
  end

  # Private API.

  defp encode(name) do
    String.replace(name, ",", "%2C")
  end

  defp do_when_persistence_enabled(action) do
    do_when_persistence_enabled(Application.get_env(:kv_server, :persistence_enabled), action)
  end

  defp do_when_persistence_enabled(true, action), do: action.()
  defp do_when_persistence_enabled(false, _action), do: nil

  defp lookup(bucket, callback) do
    case KV.Registry.lookup(KV.Registry, bucket) do
      {:ok, pid} -> callback.(pid)
      :error -> {:error, :not_found}
    end
  end

  defp transform_to_text(value) when is_map(value), do: value |> Enum.map(fn ({key, value}) -> "#{key}:#{value}" end) |> Enum.join(@separator)
  defp transform_to_text(value), do: value
end
