defmodule Slug.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    Supervisor.start_link(
      [Slug.Slack.Supervisor],
      strategy: :one_for_one,
      name: Slug.Supervisor
    )
  end
end
