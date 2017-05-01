defmodule KV.Persistence.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :kv_persistence,
      version: "1.0.0",

      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.4",

      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,

      compilers: [ :elixir_make ] ++ Mix.compilers,

      make_clean: [ "clean" ],
      make_env: %{"MIX_ENV" => to_string(Mix.env)},

      deps: deps()
    ]
  end

  def application() do
    [
      applications: []
    ]
  end

  defp deps() do
    [
      {:elixir_make, "~> 0.4", runtime: false},
      {:recon, "~> 2.3"}
    ]
  end
end
