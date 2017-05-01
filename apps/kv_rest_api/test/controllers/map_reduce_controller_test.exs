defmodule KV.RestAPI.Web.MapReduceControllerTest do
  use KV.RestAPI.Web.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "calculates average for keys in a bucket", %{conn: conn} do
    conn = post conn, "/buckets", %{"bucket" => "testing_average"}
    conn = post conn, "/buckets/testing_average/keys", %{"key" => "one", "value" => 1}
    conn = post conn, "/buckets/testing_average/keys", %{"key" => "two", "value" => 2}

    conn = post conn, "/jobs/average/testing_average"
    job = json_response(conn, 200)["job"]

    :timer.sleep(150)

    conn = get conn, "/jobs/#{job}"
    assert json_response(conn, 200) == %{"result" => "1.5"}

    delete conn, "/buckets/testing_average"
  end

  test "calculates sum for keys in a bucket", %{conn: conn} do
    conn = post conn, "/buckets", %{"bucket" => "testing_sum"}
    conn = post conn, "/buckets/testing_sum/keys", %{"key" => "one", "value" => 1}
    conn = post conn, "/buckets/testing_sum/keys", %{"key" => "two", "value" => 2}

    conn = post conn, "/jobs/sum/testing_sum"
    job = json_response(conn, 200)["job"]

    :timer.sleep(150)

    conn = get conn, "/jobs/#{job}"
    assert json_response(conn, 200) == %{"result" => "3.0"}

    delete conn, "/buckets/testing_sum"
  end

  test "calculates word count for a key in bucket", %{conn: conn} do
    conn = post conn, "/buckets", %{"bucket" => "testing_word_count"}
    conn = post conn, "/buckets/testing_word_count/keys", %{"key" => "one", "value" => "A A B C D B E D D A"}

    conn = post conn, "/jobs/wordcount/testing_word_count/one"
    job = json_response(conn, 200)["job"]

    :timer.sleep(150)

    conn = get conn, "/jobs/#{job}"
    assert json_response(conn, 200) == %{"result" => "A:3,B:2,C:1,D:3,E:1"}

    delete conn, "/buckets/testing_word_count"
  end
end
