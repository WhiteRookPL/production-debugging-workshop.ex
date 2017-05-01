defmodule KV.GarbageCollector do
  @moduledoc """
  Module which expires keys in buckets, built on top of lightweight `OTP` processes (`proc_lib`).
  """

  # Client API.

  @doc """
  Starts the garbage collection process with a given name that handles keys expiration.
  """
  def start_link(name) do
    :proc_lib.start_link(__MODULE__, :init, [ self(), name ])
  end

  def expire_key_after(bucket, key, ttl) do
    Process.send(Process.whereis(__MODULE__), {:expire_key_after, bucket, key, ttl}, [])
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

  def write_debug(device, event, name) do
    IO.inspect(device, "CUSTOM WRITE DEBUG: #{name} event = #{event}")
  end

  def system_replace_state(modify_state_fun, state) do
    updated_state = modify_state_fun.(state)
    {:ok, updated_state, updated_state}
  end

  def system_code_change(state, _module, _old_version, _extra) do
    {:ok, state}
  end

  def init(parent, name) do
    opts = :sys.debug_options([])

    :proc_lib.init_ack(parent, {:ok, self()})
    Process.register(self(), name)

    loop(parent, opts, %{})
  end

  # Private API.

  defp loop(parent, opts, state) do
    receive do
      {:expire_key_after, bucket, key, ttl} ->
        modified_opts = :sys.handle_debug(opts, &write_debug/3, __MODULE__, {:in, :expire_key_after, bucket, key, ttl})

        Process.send_after(self(), {:expired, bucket, key}, ttl)

        new_opts = :sys.handle_debug(modified_opts, &write_debug/3, __MODULE__, {:out, :expired, bucket, key})

        loop(parent, new_opts, Map.put(state, key, ttl))

      {:expired, bucket, key} ->
        new_opts = :sys.handle_debug(opts, &write_debug/3, __MODULE__, {:in, :expired, bucket, key})

        KV.Bucket.delete(bucket, key)

        loop(parent, new_opts, Map.delete(state, key))

      {:system, from, request} ->
        :sys.handle_system_msg(request, from, parent, __MODULE__, opts, state)
        loop(parent, opts, state)

      _ ->
        loop(parent, opts, state)
    end
  end
end