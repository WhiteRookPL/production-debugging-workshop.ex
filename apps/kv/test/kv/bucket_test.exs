defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = KV.Bucket.start_link
    {:ok, bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "milk") == nil

    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3
  end

  test "checks that value can be streamed out from bucket", %{bucket: bucket} do
    KV.Bucket.put(bucket, "milk", "1234567890")

    assert KV.Bucket.get_stream(bucket, "milk") |> Enum.to_list == [ "1234567890" ]
  end
end
