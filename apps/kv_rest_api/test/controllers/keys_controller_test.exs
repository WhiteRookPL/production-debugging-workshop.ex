defmodule KV.RestAPI.Web.KeysControllerTest do
  use KV.RestAPI.Web.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all keys for bucket", %{conn: conn} do
    conn = post conn, "/buckets", %{"bucket" => "foo"}
    conn = post conn, "/buckets/foo/keys", %{"key" => "one", "value" => 1}
    conn = post conn, "/buckets/foo/keys", %{"key" => "two", "value" => 2}

    conn = get conn, "/buckets/foo/keys"
    assert json_response(conn, 200) == [ "one", "two" ]
  end

  test "checks that non-existing key should be handled", %{conn: conn} do
    conn = post conn, "/buckets", %{"bucket" => "baz"}
    conn = get conn, "/buckets/baz/keys/one"

    assert json_response(conn, 404) == %{"errors" => %{"detail" => "Not found"}}

    delete conn, "/buckets/baz"
  end

  test "creates key in the bucket, returns proper status code and you are able to return value from it", %{conn: conn} do
    conn = post conn, "/buckets", %{"bucket" => "foo"}
    conn = post conn, "/buckets/foo/keys", %{"key" => "one", "value" => 1}
    assert json_response(conn, 201) == %{"status" => "Key one in bucket foo created."}

    conn = get conn, "/buckets/foo/keys/one"
    assert json_response(conn, 200) == %{"value" => "1"}
  end

  test "creates TTL based key in the bucket, returns proper status code and you are able to return value from it", %{conn: conn} do
    conn = post conn, "/buckets", %{"bucket" => "foo"}
    conn = post conn, "/buckets/foo/keys", %{"key" => "one", "value" => 1, "ttl" => 100}
    assert json_response(conn, 201) == %{"status" => "Key one in bucket foo created with TTL: 100."}

    conn = get conn, "/buckets/foo/keys/one"
    assert json_response(conn, 200) == %{"value" => "1"}

    :timer.sleep(150)

    conn = get conn, "/buckets/foo/keys/one"
    assert json_response(conn, 404) == %{"errors" => %{"detail" => "Not found"}}
  end

  test "deletes key in the bucket and returns proper status code", %{conn: conn} do
    conn = post conn, "/buckets", %{"bucket" => "bar"}
    conn = post conn, "/buckets/bar/keys", %{"key" => "for_delete", "value" => "doesn't matter"}

    conn = get conn, "/buckets/bar/keys"
    assert json_response(conn, 200) == [ "for_delete" ]

    conn = delete conn, "/buckets/bar/keys/for_delete"
    assert json_response(conn, 204) == %{"status" => "Key for_delete in bucket bar deleted."}

    conn = get conn, "/buckets/bar/keys"
    assert json_response(conn, 200) == []

    delete conn, "/buckets/bar"
  end
end