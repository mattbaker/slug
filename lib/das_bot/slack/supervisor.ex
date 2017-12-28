defmodule DasBot.Slack.Supervisor do
  @moduledoc false

  use Supervisor
  alias DasBot.Slack

  def start_link(api_token) do
    Supervisor.start_link(__MODULE__, api_token, [])
  end

  def init(api_token) do
    children = [
      {Slack, token: api_token}
    ]

    Supervisor.init(children, strategy: :one_for_one, name: __MODULE__)
  end
end
