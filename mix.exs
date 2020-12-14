defmodule Purely.Mixfile do
  use Mix.Project

  def project do
    [
      app: :purely,
      version: "0.0.1",
      elixir: "~> 1.2",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:credo, "~> 1.5.3", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev, :test]},
      {:ex_doc, "~> 0.18", only: :dev},
      {:stream_data, "~> 0.1", only: :test}
    ]
  end
end
