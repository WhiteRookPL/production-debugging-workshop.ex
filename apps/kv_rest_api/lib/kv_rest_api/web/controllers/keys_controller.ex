defmodule KV.RestAPI.Web.KeysController do
  use KV.RestAPI.Web, :controller

  def index(conn, %{"bucket" => bucket}) do
    with keys = KV.RestAPI.Command.Server.execute(:keys, [ bucket ]) do
      conn
      |> put_status(:ok)
      |> json(keys)
    end
  end

  def get(conn, %{"bucket" => bucket, "key" => key}) do
    case KV.RestAPI.Command.Server.execute(:get, [ bucket, key ]) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render(KV.RestAPI.Web.ErrorView, "404.json")

      value ->
        conn
        |> put_status(:ok)
        |> json(%{"value" => value})
    end
  end

  def create(conn, %{"bucket" => bucket, "key" => key, "value" => value, "ttl" => ttl}) do
    case KV.RestAPI.Command.Server.execute(:create, [ bucket, key, value, ttl ]) do
      :error ->
        conn
        |> put_status(500)
        |> render(KV.RestAPI.Web.ErrorView, "500.json")

      :ok ->
        conn
        |> put_status(:created)
        |> json(%{"status" => "Key #{key} in bucket #{bucket} created with TTL: #{ttl}."})
    end
  end

  def create(conn, %{"bucket" => bucket, "key" => key, "value" => value}) do
    with :ok <- KV.RestAPI.Command.Server.execute(:create, [ bucket, key, value ]) do
      conn
      |> put_status(:created)
      |> json(%{"status" => "Key #{key} in bucket #{bucket} created."})
    end
  end

  def delete(conn, %{"bucket" => bucket, "key" => key}) do
    with :ok <- KV.RestAPI.Command.Server.execute(:delete, [ bucket, key ]) do
      conn
      |> put_status(:no_content)
      |> json(%{"status" => "Key #{key} in bucket #{bucket} deleted."})
    end
  end
end
