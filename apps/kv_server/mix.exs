defmodule KV.Server.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :kv_server,
      version: "1.0.0",

      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",

      elixir: "~> 1.4",

      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,

      deps: deps()
    ]
  end

  def application() do
    [
      applications: [
        :logger,
        :kv,
        :kv_map_reduce,
        :kv_persistence
      ],
      mod: {KV.Server, []}
    ]
  end

  defp deps() do
    [
      {:kv, in_umbrella: true},
      {:kv_map_reduce, in_umbrella: true},
      {:kv_persistence, in_umbrella: true}
    ]
  end
end
