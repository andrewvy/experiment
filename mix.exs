defmodule Experiment.Mixfile do
  use Mix.Project

  @version "0.0.1"

  def project do
    [
      app: :experiment,
      version: @version,
      elixir: "~> 1.2",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,

      # Hex
      description: description,
      package: package,

      deps: deps
   ]
  end

  defp description do
    """
    Experiment is a library for carefully refactoring critical paths in production.
    """
  end

  defp package do
    [maintainers: ["Andrew Vy"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/andrewvy/experiment"},
     files: ~w(mix.exs README.md lib)]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    []
  end
end
