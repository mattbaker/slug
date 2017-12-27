defmodule DasBot.Slug.Common.MessagesOnly do
  @behaviour DasBot.Slug
  alias DasBot.Slug.Event

  def call(%Event{data: %{type: "message", edited: _}}, _bot), do: :halt
  def call(%Event{data: %{type: "message", text: _, user: _}} = event, _bot), do: event
  def call(_, _), do: :halt
end
