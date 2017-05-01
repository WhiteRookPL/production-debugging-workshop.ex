defmodule KV.MapReduce.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :kv_map_reduce,
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
        :gen_stage,
        :flow
      ],
      mod: {KV.MapReduce, []}
    ]
  end

  defp deps() do
    [
      {:gen_stage, "~> 0.11"},
      {:flow, "~> 0.11"},
      {:kv, in_umbrella: true}
    ]
  end
end
