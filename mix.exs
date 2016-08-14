defmodule Purely.Mixfile do
  use Mix.Project

  def project do
    [app: :purely,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.13", only: :dev},
      {:dialyxir, "~> 0.3", only: [:dev]},
      {:excheck, "~> 0.3", only: :test},
      {:triq, github: "krestenkrab/triq", only: :test}
    ]
  end
end
