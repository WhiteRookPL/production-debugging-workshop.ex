defmodule KvUmbrella.Mixfile do
  use Mix.Project

  def project() do
    [
      apps_path: "apps",

      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,

      deps: deps()
    ]
  end

  def application() do
    [
      applications: [
        :kv_rest_api
      ]
    ]
  end

  defp deps() do
    [
      {:distillery, "~> 1.0"},
      {:xprof, "~> 1.2"},
      {:eper, "~> 0.94"},
      {:dbg, "~> 1.0"},
      {:recon, "~> 2.3"}
    ]
  end
end
