defmodule DasBot do
  @moduledoc """
  DasBot is a Slack bot framework inspired by [Plug](https://github.com/elixir-plug/plug).

  Slack bots may be defined by using `DasBot.Bot` and assembling a pipeline of `DasBot.Slug`s.

  Slugs are like [Plugs](https://github.com/elixir-plug/plug), but for Slack.

  To get started, take a look at the `DasBot.Bot` module.
  """

  @doc false
  def get_env(key) do
    Application.get_env(:das_bot, key)
  end
end
