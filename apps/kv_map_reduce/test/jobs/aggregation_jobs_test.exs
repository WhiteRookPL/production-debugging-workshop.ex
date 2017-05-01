defmodule KV.MapReduce.AggregationJobsTest do
  use ExUnit.Case

  setup do
    Application.stop(:kv)
    :ok = Application.start(:kv)
  end

  setup do
    {:ok, bucket} = KV.Bucket.start_link
    {:ok, bucket: bucket}
  end

  test "that calculates the average of the keys in the bucket", %{bucket: bucket} do
    KV.Bucket.put(bucket, "one", 3)
    KV.Bucket.put(bucket, "two", 3)
    KV.Bucket.put(bucket, "three", 3)

    {:ok, id} = KV.MapReduce.Scheduler.new_job(KV.MapReduce.Scheduler, :avg, bucket)
    :timer.sleep(100)

    assert KV.MapReduce.Scheduler.get_job_result(KV.MapReduce.Scheduler, id) == 3
  end

  test "that calculates the sum of the keys in the bucket", %{bucket: bucket} do
    KV.Bucket.put(bucket, "one", 3)
    KV.Bucket.put(bucket, "two", 3)
    KV.Bucket.put(bucket, "three", 3)

    {:ok, id} = KV.MapReduce.Scheduler.new_job(KV.MapReduce.Scheduler, :sum, bucket)
    :timer.sleep(100)

    assert KV.MapReduce.Scheduler.get_job_result(KV.MapReduce.Scheduler, id) == 9
  end

  test "that getting result for non-existing job will not crash", _context do
    assert KV.MapReduce.Scheduler.get_job_result(KV.MapReduce.Scheduler, 100) == :no_such_job
  end
end
