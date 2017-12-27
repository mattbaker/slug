defmodule DasBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: DasBot.Worker.start_link(arg)
      # {DasBot.Worker, arg},
      {DasBot.Slack.Supervisor, DasBot.get_env(:slack_api_token)}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DasBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
