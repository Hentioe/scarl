defmodule Bot.MixProject do
  use Mix.Project

  def project do
    [
      app: :bot,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Bot.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      # {:sibling_app_in_umbrella, in_umbrella: true},
      {:distillery, "~> 2.0", runtime: false},
      {:pubg, in_umbrella: true},
      {:nostrum, git: "https://github.com/Kraigie/nostrum.git"},
      {:credo, "~> 0.10.0"},
      {:httpoison, "~> 1.2", override: true},
      {:poison, "~> 4.0", override: true}
    ]
  end
end
