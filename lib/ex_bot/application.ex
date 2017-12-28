defmodule ExBot.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    Supervisor.start_link(
      [ExBot.Slack.Supervisor],
      strategy: :one_for_one,
      name: ExBot.Supervisor
    )
  end
end
