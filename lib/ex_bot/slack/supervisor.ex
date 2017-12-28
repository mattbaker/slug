defmodule ExBot.Slack.Supervisor do
  @moduledoc false

  use Supervisor
  alias ExBot.Slack

  def start_link([]) do
    Supervisor.start_link(__MODULE__, [], [])
  end

  def init([]) do
    children = [Slack]
    Supervisor.init(children, strategy: :one_for_one, name: __MODULE__)
  end
end
