defmodule DasBot.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    Supervisor.start_link(
      [DasBot.Slack.Supervisor],
      strategy: :one_for_one,
      name: DasBot.Supervisor
    )
  end
end
