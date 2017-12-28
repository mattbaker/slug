defmodule ExBot.Slug.Common.CheckMentioned do
  @moduledoc """
  A slug that checks if the bot has been mentioned.

  Attaches the key `:mentioned` to the `ExBot.Event`'s metadata with the value
  `true` if the bot was mentioned in this message, and `false` if it was not.

  Expects `ExBot.Event` to be a message, you may need to filter non-message events
  out of the pipeline before using this. See `ExBot.Slug.Common.MessagesOnly`.

  """
  @behaviour ExBot.Slug
  alias ExBot.Event

  @impl true
  def call(event, _bot) do
    %Event{
      bot_id: bot_id,
      data: %{text: message},
      metadata: %{bot_name: bot_name}
    } = event

    is_mentioned = Regex.match?(~r/.*(<@#{bot_id}>|@#{bot_name}).*/, message)
    event |> Event.add_metadata(:mentioned, is_mentioned)
  end
end
