defmodule KV.RestAPI.Web.BucketsControllerTest do
  use KV.RestAPI.Web.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = post conn, "/buckets", %{"bucket" => "foo"}
    conn = get conn, "/buckets"

    assert json_response(conn, 200) == [ "foo" ]
  end

  test "creates buckets and returns proper status code", %{conn: conn} do
    conn = post conn, "/buckets", %{"bucket" => "foo"}
    assert json_response(conn, 201) == %{"status" => "Bucket foo created."}

    conn = get conn, "/buckets"
    assert json_response(conn, 200) == [ "foo" ]
  end

  test "deletes buckets and returns proper status code", %{conn: conn} do
    conn = post conn, "/buckets", %{"bucket" => "foo"}
    conn = get conn, "/buckets"
    assert json_response(conn, 200) == [ "foo" ]

    conn = delete conn, "/buckets/foo"
    assert json_response(conn, 204) == %{"status" => "Bucket foo deleted."}

    conn = get conn, "/buckets"
    assert json_response(conn, 200) == []
  end

  # test "checks that deletion of non-existing buckets returns proper status code", %{conn: conn} do
  #   conn = delete conn, "/buckets/foo"
  #   assert json_response(conn, 404) == %{"errors" => %{"detail" => "Not found"}}
  # end
end
