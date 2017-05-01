defmodule KV.RestAPI.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :kv_rest_api,
      version: "1.0.0",

      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",

      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),

      compilers: [:phoenix ] ++ Mix.compilers,

      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,

      deps: deps()
    ]
  end

  def application() do
    [
      mod: {KV.RestAPI.Application, []},
      extra_applications: [
        :logger,
        :kv_server
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps() do
    [
      {:phoenix, "~> 1.3.0-rc"},
      {:phoenix_pubsub, "~> 1.0"},
      {:cowboy, "~> 1.0"},
      {:kv_server, in_umbrella: true}
    ]
  end
end
