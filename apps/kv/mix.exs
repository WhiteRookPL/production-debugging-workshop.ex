defmodule KV.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :kv,
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
        :logger
      ],
      mod: {KV, []}
    ]
  end

  defp deps() do
    [
    ]
  end
end
