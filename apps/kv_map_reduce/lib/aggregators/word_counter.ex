defmodule KV.MapReduce.WordCounter do
  @doc """
  Starts new word counting job with use of new `GenState` and
  `Flow` *Elixir* libraries
  """
  def start(parent, id, bucket, key) do
    per_line = Flow.Window.global |> Flow.Window.trigger_every(1, :reset)

    pid = spawn(fn() ->
      result =
        KV.Bucket.get_stream(bucket, key)
        |> Flow.from_enumerable(window: per_line)
        |> Flow.flat_map(&String.split(&1, " "))
        |> Flow.reduce(fn() -> %{} end, &update_word_count/2)
        |> Enum.into(%{})

      GenServer.cast(parent, {:finished, id, result})
    end)

    {:ok, pid}
  end

  # Private functions.

  defp update_word_count("", map),  do: map
  defp update_word_count(word, map) do
    Map.update(map, word, 1, &(&1 + 1))
  end
end
