defmodule KV.MapReduce.Job do
  require Logger

  defmodule State do
    @moduledoc """
    Module which represents state of the aggregation job.
    """

    defstruct id: 0, type: nil, bucket: nil, result: [], start_time: 0
  end

  @moduledoc """
  Module which represents aggregation jobs built on top of lightweight `OTP` processes (`proc_lib`).
  """

  # Client API

  @doc """
  Starting point for a job which need to be performed.
  It casts result to its parent.
  """
  def start(id, type, bucket) do
    state = %State{
      id: id,
      type: type,
      bucket: bucket,
      start_time: System.system_time()
    }

    :proc_lib.start_link(__MODULE__, :init, [ self(), state ])
  end

  # Required functions for `:proc_lib`.

  def system_continue(parent, opts, state) do
    loop(parent, opts, state)
  end

  def system_terminate(reason, _parent, _opts, _state) do
    exit(reason)
  end

  def system_get_state(state) do
    {:ok, state}
  end

  defp write_debug(device, event, name) do
    :io.format(device, "~p event = ~p~n", [ name, event ])
  end

  def system_replace_state(modify_state_fun, state) do
    updated_state = modify_state_fun.(state)
    {:ok, updated_state, updated_state}
  end

  def system_code_change(state, _module, _old_version, _extra) do
    {:ok, state}
  end

  def init(parent, state) do
    opts = :sys.debug_options([])

    :proc_lib.init_ack(parent, {:ok, self()})

    send(self(), :get_keys)
    loop(parent, opts, state)
  end

  # Private functions.

  defp loop(parent, opts, %State{id: id, type: type, bucket: bucket, result: result, start_time: start_time} = state) do
    receive do
      :get_keys ->
        new_opts = :sys.handle_debug(opts, &write_debug/3, __MODULE__, {:in, :get_keys})

        send(self(), :aggregation)
        keys = KV.Bucket.keys(bucket)

        loop(parent, new_opts, %{state | result: keys})

      :aggregation ->
        new_opts = :sys.handle_debug(opts, &write_debug/3, __MODULE__, {:in, :aggregate})

        send(self(), :final_aggregation_step)
        aggregate = aggregation(bucket, result)

        loop(parent, new_opts, %{state | result: aggregate})

      :final_aggregation_step ->
        new_opts = :sys.handle_debug(opts, &write_debug/3, __MODULE__, {:in, :final_aggregation_step})

        send(self(), :return_result)
        final_aggregate = final_aggregation_step(type, result)

        loop(parent, new_opts, %{state | result: final_aggregate})

      :return_result ->
        :sys.handle_debug(opts, &write_debug/3, __MODULE__, {:in, :return_result})

        GenServer.cast(parent, {:finished, id, result})

        end_time = System.system_time()
        Logger.info("Job #{id} took #{System.convert_time_unit(end_time - start_time, :native, :milliseconds)} ms")

      {:system, from, request} ->
        :sys.handle_system_msg(request, from, parent, __MODULE__, opts, state)
        loop(parent, opts, state)
    end
  end

  defp aggregation(bucket, keys) do
    sum = Enum.reduce(keys, 0, fn(key, accumulator) ->
      accumulator + convert(KV.Bucket.get(bucket, key))
    end)

    {length(keys), sum}
  end

  defp convert(value) when is_number(value), do: value
  defp convert(value) when is_binary(value), do: parser(Float.parse(value))
  defp convert(_), do: 0

  defp parser(:error), do: 0
  defp parser({value, _rest}), do: value

  defp final_aggregation_step(:avg, {size, sum}) do
    sum / size
  end

  defp final_aggregation_step(:sum, {_size, sum}) do
    sum
  end
end
