defmodule DasBot.Slug do
  @moduledoc """

  The slug specification. Slugs are like [Plug](https://github.com/elixir-plug/plug)s, but for Slack.

  What do slugs do? They...

   * Receive events from Slack.
   * Perform any actions they desire as a reaction to the event. For example, sending a message, or adding a reaction.
   * Optionally annotate the event they received with metadata that may be helpful to other slugs.
   * Return the event, passing it on to the next slug in the pipeline.

  In addition to the documentation below, check out the bundled slugs and associated tests under the `DasBot.Slug.Common` namespace for examples.

  ## The Slug Pipeline

  Many slugs are strung together inside of a `DasBot.Bot` module to build a slug pipeline.

  A bot's pipeline of slugs defines how a bot reacts to events coming from the Slack [RTM API](https://api.slack.com/rtm).

  ## Kinds of Slugs
  There are two kind of slugs: function slugs and module slugs.

  ### Function slugs

  A function slug is any function that receives a `DasBot.Event` and returns a `DasBot.Event` or `:halt`.
  Its type signature must be:

      (DasBot.Event.t) :: DasBot.Event.t

  ### Module slugs

  A module slug is an extension of the function slug. The API expected by a module slug is defined as a behaviour by the
  `DasBot.Slug` module (this module), specifically the export of `c:call/2`.

  ## Examples

  ### Function Slug

  Here's an example of a function slug that logs out the event it receives. Later slugs may like to know that an inspection
  occurred, so this slug also makes a note in the metadata that it inspected the event.

  ```
  def simple_reply(%DasBot.Event{data: %{user: user_id, channel: channel_id}} = event) do
    IO.inspect("Event from \#{user_id} in channel \#{channel_id}: \#{inspect(event)}")
    event |> Event.add_metadata(:got_inspected, true)
  end
  ```

  ### Module Slug

  Here's an example of a module slug that checks if the bot was mentioned
  in a Slack message and annotates the `DasBot.Event`'s metadata accordingly.

  ```
  defmodule DasBot.Slug.Common.CheckMentioned do
    @behaviour DasBot.Slug

    def call(event, _bot) do
      %DasBot.Event{
        bot_id: bot_id,
        data: %{text: message},
        metadata: %{bot_name: bot_name}
      } = event

      is_mentioned = Regex.match?(~r/.*(<@\#{bot_id}>|@\#{bot_name}).*/, message)
      event |> DasBot.Event.add_metadata(:mentioned, is_mentioned)
    end
  end
  ```

  ## Don't forget the catch-all

  If your slug function, or module, uses pattern matching in its clause you probably want to provide
  a catch-all clause that passes on any event that is not recognized.

  ```
  def simple_slug(%DasBot.Event{data: %{user: "UTEST"}} = event) do
    IO.puts("The test user produced an event")
    event
  end

  #Ignore and forward any events that don't match the clause above
  def simple_slug(event), do: event
  ```

  If you actually want to halt the progress of the pipeline, return `:halt` from your slug.

  """
  @doc """
  Takes a `DasBot.Event` and the `DasBot.Bot` module that received the event.
  Must return a `DasBot.Event` or `:halt`.

  Returning `:halt` will abort the pipeline execution, and subsequent slugs in the pipeline will not be run.
  """
  @callback call(event :: DasBot.Event.t(), bot :: DasBot.Bot.t()) :: DasBot.Event.t() | :halt
end
