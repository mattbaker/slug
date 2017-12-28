defmodule DasBot.Slug.Common.MessagesOnly do
  @moduledoc """
  Filters out Slack events that are not messages. For example, this will filter out
  events indicating that a new user has joined the channel.

  Helpful if you have downstream slugs that are expecting to receive message events.
  """
  @behaviour DasBot.Slug
  alias DasBot.Event

  @impl true
  def call(%Event{data: %{type: "message", edited: _}}, _bot), do: :halt
  @impl true
  def call(%Event{data: %{type: "message", text: _, user: _}} = event, _bot), do: event
  @impl true
  def call(_, _), do: :halt
end
