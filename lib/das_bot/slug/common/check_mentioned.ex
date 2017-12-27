defmodule DasBot.Slug.Common.CheckMentioned do
  @behaviour DasBot.Slug
  alias DasBot.Slug.Event

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
