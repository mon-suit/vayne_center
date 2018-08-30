defmodule VayneCenter.MixProject do
  use Mix.Project

  def project do
    [
      app: :vayne_center,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Vayne.Center, []},
      included_applications: [:trot],
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:trot, "~> 0.6.1"},
      {:cipher, "~> 1.4"},
      {:inet_cidr, "~> 1.0"},
      {:distillery, "~> 1.5"},
      {:falcon_plus_api, github: "mon-suit/falcon-plus-api", branch: "mon-suit"},
      {:logger_file_backend, "~> 0.0.10"},
      {:vayne, github: "mon-suit/vayne_core", runtime: false},
    ]
  end
end
