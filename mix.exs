defmodule DasBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :das_bot,
      version: "0.1.0",
      name: "DasBot",
      description: "Like Plug, but for Slack Bots.",
      package: package(),
      maintainers: "",
      elixir: "~> 1.6-dev",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs()
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
      {:websocket_client, "~> 1.3.0"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end

  defp package() do
    %{
      licenses: ["MIT License"],
      maintainers: ["Matt Baker"],
      links: %{"GitHub" => "https://github.com/mattbaker/das-bot"}
    }
  end

  defp docs() do
    [extras: ["README.md"], main: "readme"]
  end
end
