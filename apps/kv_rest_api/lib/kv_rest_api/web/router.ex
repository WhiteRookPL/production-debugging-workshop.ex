defmodule KV.RestAPI.Web.Router do
  use KV.RestAPI.Web, :router

  pipeline :api do
    plug :accepts, [ "json" ]

    get "/buckets", KV.RestAPI.Web.BucketsController, :index
    post "/buckets", KV.RestAPI.Web.BucketsController, :create
    delete "/buckets/:bucket", KV.RestAPI.Web.BucketsController, :delete

    get "/buckets/:bucket/keys", KV.RestAPI.Web.KeysController, :index
    get "/buckets/:bucket/keys/:key", KV.RestAPI.Web.KeysController, :get
    post "/buckets/:bucket/keys", KV.RestAPI.Web.KeysController, :create
    delete "/buckets/:bucket/keys/:key", KV.RestAPI.Web.KeysController, :delete

    post "/jobs/average/:bucket", KV.RestAPI.Web.MapReduceController, :avg
    post "/jobs/sum/:bucket", KV.RestAPI.Web.MapReduceController, :sum
    post "/jobs/wordcount/:bucket/:key", KV.RestAPI.Web.MapReduceController, :word_count
    get "/jobs/:id", KV.RestAPI.Web.MapReduceController, :result

    get "/debug/commands", KV.RestAPI.Web.DebugController, :history
  end

  scope "/", KV.RestAPI.Web do
    pipe_through :api
  end
end
