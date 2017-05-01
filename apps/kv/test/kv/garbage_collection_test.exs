defmodule KV.GarbageCollectionTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = KV.Bucket.start_link
    {:ok, bucket: bucket}
  end

  test "checks that certain keys will expire", %{bucket: bucket} do
    KV.Bucket.putx(bucket, "milk", 1, 100)

    assert KV.Bucket.get(bucket, "milk") == 1

    :timer.sleep(110)

    assert KV.Bucket.get(bucket, "milk") == nil
  end
end
