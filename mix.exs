defmodule DasBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :das_bot,
      version: "0.1.0",
      elixir: "~> 1.6-dev",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {DasBot.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 3.0"},
      {:httpoison, "~> 0.13"},
      {:websocket_client, "~> 1.3.0", manager: :rebar},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end
end
