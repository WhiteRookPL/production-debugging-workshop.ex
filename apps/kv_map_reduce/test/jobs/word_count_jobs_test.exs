defmodule KV.MapReduce.WordCountJobsTest do
  use ExUnit.Case

  setup do
    Application.stop(:kv)
    :ok = Application.start(:kv)
  end

  setup do
    {:ok, bucket} = KV.Bucket.start_link
    {:ok, bucket: bucket}
  end

  test "that calculates the word count from key values in the bucket", %{bucket: bucket} do
    KV.Bucket.put(bucket, "one", "one word one two word work one")

    {:ok, id} = KV.MapReduce.Scheduler.new_word_count_job(KV.MapReduce.Scheduler, bucket, "one")
    :timer.sleep(100)

    assert KV.MapReduce.Scheduler.get_job_result(KV.MapReduce.Scheduler, id) == %{"one" => 3, "two" => 1, "word" => 2, "work" => 1}
  end

  test "that calculates the word count from key value with more words in the bucket", %{bucket: bucket} do
    KV.Bucket.put(bucket, "two", "one word one two word work one\none word one two word work one\n")

    {:ok, id} = KV.MapReduce.Scheduler.new_word_count_job(KV.MapReduce.Scheduler, bucket, "two")
    :timer.sleep(100)

    assert KV.MapReduce.Scheduler.get_job_result(KV.MapReduce.Scheduler, id) == %{"one" => 6, "two" => 2, "word" => 4, "work" => 2}
  end
end