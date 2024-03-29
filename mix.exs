defmodule MRP.MixProject do
  use Mix.Project

  def project do
    [
      app: :mrp,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {MRP.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # web
      {:phoenix, "~> 1.7"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_view, "~> 0.19"},
      {:heroicons, "~> 0.5"},
      {:phoenix_live_dashboard, "~> 0.8"},
      {:gettext, "~> 0.22"},
      {:plug_cowboy, "~> 2.6"},

      # other
      {:bcrypt_elixir, "~> 3.0"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:swoosh, "~> 1.10"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:jason, "~> 1.5-alpha.1"},
      {:oban, "~> 2.15"},
      {:finch, "~> 0.16"},
      {:mjml, "~> 1.5"},
      {:triplex, "~> 1.3.0"},

      # i18n
      {:ex_cldr_plugs, "~> 1.3"},
      {:ex_cldr, "~> 2.37"},
      {:ex_money, "~> 5.13"},
      {:ex_cldr_dates_times, "~> 2.13"},
      {:ex_cldr_calendars, "~> 1.22"},

      # dev & test
      {:faker, "~> 0.17", only: [:test, :dev]},
      {:phoenix_live_reload, "~> 1.4", only: :dev},
      {:floki, "~> 0.34", only: :test},
      {:credo, "~> 1.7", only: :dev},
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "ecto.seed"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.seed": ["run priv/repo/seeds.exs"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
