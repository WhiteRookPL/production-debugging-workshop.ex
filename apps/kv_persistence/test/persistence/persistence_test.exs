defmodule KV.PersistenceTest do
  use ExUnit.Case, async: true

  test "do a sanity check for NIF module" do
    assert KV.Persistence.clear_persistence() == :ok

    assert KV.Persistence.store({:create, "a"}) == {:ok, 1}
    assert KV.Persistence.store({:create, "b"}) == {:ok, 1}

    assert KV.Persistence.restore() == {:ok, ["CREATE a", "CREATE b"]}
  end
end
