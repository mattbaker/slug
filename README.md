# DasBot

DasBot is like [Plug](https://github.com/elixir-plug/plug), but for Slack.

```elixir
defmodule MyBot do
  use DasBot.Bot

  slug(DasBot.Slug.Common.MessagesOnly)
  slug(DasBot.Slug.Common.CheckMentioned)
  slug(:simple_reply)

  def simple_reply(%DasBot.Event{data: %{user: user_id}, metadata: %{mentioned: true}} = event) do
    DasBot.Bot.send_to_channel(__MODULE__, "general", "Oh hey, <@\#{user_id}>!")
    event
  end
  def simple_reply(event), do: event
end

defmodule MyBot.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {MyBot, token: "xoxb-my-bot-token"}
    ]

    opts = [strategy: :one_for_one, name: TestBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `das_bot` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:das_bot, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/das_bot](https://hexdocs.pm/das_bot).

