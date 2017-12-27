defmodule DasBot.Slug.Common.FilterSelf do
  @behaviour DasBot.Slug
  alias DasBot.Slug.Event

  def call(%Event{bot_id: bot_id, data: %{user: bot_id}}, _bot), do: :halt
  def call(event, _bot), do: event
end
