# ExBot

ExBot is like [Plug](https://github.com/elixir-plug/plug), but for Slack.
Your bot module defines a pipeline of functions (slugs) that receive events from Slack. Each slug can take actions in response to the events it receives, and may optionally add metadata to an event for other slugs to use downstream. This is similar to Plug and its `conn` object.

ExBot connects and communicates over websocket using Slack's [RTM API](https://api.slack.com/rtm). A simple `ExBot.Slack` process also provides access to a few handy Web API calls, and maintains a cache of user and channel information for quick lookups.

Hex docs for ExBot are available [here](https://hexdocs.pm/ex_bot).

## Installation and example

Start a new project.

```elixir
mix new bot_family --sup
```

Add `ExBot` to your deps, then run `mix deps.get`.

```elixir
def deps do
  [
    {:ex_bot, "~> 0.1.0"}
  ]
end
```

#### Create your Bot
Create a new module for your bot, pull in `ExBot.Bot`, and define a simple pipeline of slugs.

```elixir
# lib/bot_family/my_bot.ex
defmodule BotFamily.MyBot do
  use ExBot.Bot

  slug(ExBot.Slug.Common.MessagesOnly)
  slug(ExBot.Slug.Common.CheckMentioned)
  slug(:simple_reply)

  def simple_reply(%ExBot.Event{data: event_data, metadata: %{mentioned: true}} = event) do
    %{user: user_id, channel: channel_id} = event_data
    ExBot.Bot.send_text(__MODULE__, channel_id, "Oh hey, <@#{user_id}>!")
    event
  end

  def simple_reply(event), do: event
end
```

What's going on here? In our example bot we're using the included `ExBot.Slug.Common.MessagesOnly` slug module to filter out events that are _not_ message events. 

Next we use the included `ExBot.Slug.Common.CheckMentioned` slug, which will check to see if our bot was mentioned in the message we just received. It will add a `mentioned` key to the metadata. 

Finally, we supply our own slug called `simple_reply`. If it's been mentioned, it will send a reply to the user that mentioned it in the channel using `ExBot.Bot.send_text/3`. If not, it will simply pass the event along.

Check out the documentation in the `ExBot.Slug` module for more information on creating your own slugs.

#### Configure your keys
Before we try out our bot, we need to configure the api keys for our bot in `confix/config.exs`, and for the Slack Web API. In our case, we'll use the same token for both.

```elixir
# config/config.exs
use Mix.Config

config :ex_bot,
  keys: %{
    :web_api => "xoxb-your-key",
    BotFamily.MyBot => "xoxb-your-key"
  }
```

#### Hello World.

Now let's boot our bot in `iex`. **Make sure your bot has been invited to, and joined, the channel you are using.**

```bash
$ iex -S mix
iex(1)> BotFamily.MyBot.start_link()

10:52:55.558 [info]  Elixir.MyBot: Initializing Websocket
{:ok, #PID<0.253.0>}

iex(1)> ExBot.Bot.send_to_channel(BotFamily.MyBot, "general", "hello world")
```

Check out the documentation in the `ExBot.Bot` module for more information on sending messages from your bot.

#### Test your slug pipeline

You should see a "hello world" from your bot in `#general` (assuming the bot is in that channel).

Let's test our slug pipeline. Try mentioning the bot by name in your Slack channel. For example, "Hello @mybot" (use the name of the bot you specified when you created the integration in Slack). You should see a reply.

#### Add your bot as a worker
As a last step, you probably want to add your bot as a worker to your `application.ex` instead of starting the bot explicitly.

```elixir
# lib/application.ex
defmodule BotFamily.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [BotFamily.MyBot]
    opts = [strategy: :one_for_one, name: BotFamily.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```
