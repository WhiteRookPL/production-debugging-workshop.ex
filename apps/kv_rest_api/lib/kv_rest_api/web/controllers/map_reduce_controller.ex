defmodule KV.RestAPI.Web.MapReduceController do
  use KV.RestAPI.Web, :controller

  import KV.RestAPI.Web.Router.Helpers

  def avg(conn, %{"bucket" => bucket}) do
    with id <- KV.RestAPI.Command.Server.execute(:avg, [ bucket ]) do
      conn
      |> put_status(:ok)
      |> put_resp_header("location", map_reduce_url(conn, :result, id))
      |> json(%{"job" => id})
    end
  end

  def sum(conn, %{"bucket" => bucket}) do
    with id <- KV.RestAPI.Command.Server.execute(:sum, [ bucket ]) do
      conn
      |> put_status(:ok)
      |> put_resp_header("location", map_reduce_url(conn, :result, id))
      |> json(%{"job" => id})
    end
  end

  def word_count(conn, %{"bucket" => bucket, "key" => key}) do
    case KV.RestAPI.Command.Server.execute(:word_count, [ bucket, key ]) do
      :not_found ->
        conn
        |> put_status(:not_found)
        |> json(%{"status" => "Key #{key} not found in bucket #{bucket}."})

      id ->
        conn
        |> put_status(:ok)
        |> put_resp_header("location", map_reduce_url(conn, :result, id))
        |> json(%{"job" => id})
    end
  end

  def result(conn, %{"id" => id}) do
    case KV.RestAPI.Command.Server.execute(:result, [ id ]) do
      :not_found ->
        conn
        |> put_status(:not_found)
        |> render(KV.RestAPI.Web.ErrorView, "404.json")

      :error ->
        conn
        |> put_status(500)
        |> render(KV.RestAPI.Web.ErrorView, "500.json")

      result ->
        conn
        |> put_status(:ok)
        |> json(%{"result" => result})
    end
  end
end
