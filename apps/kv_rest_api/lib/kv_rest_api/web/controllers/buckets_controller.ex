defmodule KV.RestAPI.Web.BucketsController do
  use KV.RestAPI.Web, :controller

  def index(conn, _params) do
    with buckets = KV.RestAPI.Command.Server.execute(:buckets, []) do
      conn
      |> put_status(:ok)
      |> json(buckets)
    end
  end

  def create(conn, %{"bucket" => bucket}) do
    with :ok <- KV.RestAPI.Command.Server.execute(:create, [ bucket ]) do
      conn
      |> put_status(:created)
      |> json(%{"status" => "Bucket #{bucket} created."})
    end
  end

  def delete(conn, %{"bucket" => bucket}) do
    with :ok <- KV.RestAPI.Command.Server.execute(:delete, [ bucket ]) do
      conn
      |> put_status(:no_content)
      |> json(%{"status" => "Bucket #{bucket} deleted."})
    end
  end
end
