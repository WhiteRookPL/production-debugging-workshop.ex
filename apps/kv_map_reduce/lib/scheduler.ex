defmodule KV.MapReduce.Scheduler do
  use GenServer

  @moduledoc """
  Server for handling and spawning aggregation jobs.
  """

  # Client API

  @doc """
  Starts the scheduler with `name`.
  """
  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  @doc """
  Starts new job with particular `type` on specified `bucket`.
  Returns job ID.
  """
  def new_job(server, type, bucket) do
    GenServer.call(server, {:new_job, type, bucket})
  end

  @doc """
  Starts new word count job on string `key_name` in the given `bucket`.
  """
  def new_word_count_job(server, bucket, key_name) do
    GenServer.call(server, {:new_word_count_job, bucket, key_name})
  end

  @doc """
  Gathers the job result based on provided `job_id`.
  """
  def get_job_result(server, job_id) do
    GenServer.call(server, {:get_job_result, job_id})
  end

  @doc """
  Stops the scheduler.
  """
  def stop(server) do
    GenServer.stop(server)
  end

  # GenServer callbacks.

  def init(:ok) do
    jobs = %{}
    refs = %{}

    seed = 1

    {:ok, {jobs, refs, seed}}
  end

  def handle_cast({:finished, job_id, result}, {jobs, refs, seed}) do
    updated_jobs = Map.update!(jobs, job_id, fn(_) -> result end)

    updated_refs = Map.new(Enum.reject(refs, &match?({_, ^job_id}, &1)))

    {:noreply, {updated_jobs, updated_refs, seed}}
  end

  def handle_call({:new_job, type, bucket}, _from, {jobs, refs, job_id}) do
    {:ok, pid} = KV.MapReduce.Job.start(job_id, type, bucket)

    ref = Process.monitor(pid)

    updated_refs = Map.put(refs, ref, job_id)
    updated_jobs = Map.put(jobs, job_id, :in_progress)

    {:reply, {:ok, job_id}, {updated_jobs, updated_refs, job_id + 1}}
  end

  def handle_call({:new_word_count_job, bucket, key_name}, _from, {jobs, refs, job_id}) do
    {:ok, pid} = KV.MapReduce.WordCounter.start(self(), job_id, bucket, key_name)

    ref = Process.monitor(pid)

    updated_refs = Map.put(refs, ref, job_id)
    updated_jobs = Map.put(jobs, job_id, :in_progress)

    {:reply, {:ok, job_id}, {updated_jobs, updated_refs, job_id + 1}}
  end

  def handle_call({:get_job_result, job_id}, _from, {jobs, _refs, _seed} = state) do
    result =
      case Map.fetch(jobs, job_id) do
        :error ->
          :no_such_job

        {:ok, result} ->
          result
      end

    {:reply, result, state}
  end

  def handle_info({:DOWN, ref, :process, _pid, reason}, {jobs, refs, seed}) when reason != :normal do
    {job_id, updated_refs} = Map.pop(refs, ref)

    updated_jobs = Map.update!(jobs, job_id, fn(_) -> :failed end)

    {:noreply, {updated_jobs, updated_refs, seed}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
