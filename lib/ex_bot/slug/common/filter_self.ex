defmodule ExBot.Slug.Common.FilterSelf do
  @moduledoc """
  Filters out events produced by the bot itself. Helpful if you want to ignore
  any events your bot is generating.
  """
  @behaviour ExBot.Slug
  alias ExBot.Event

  @impl true
  def call(%Event{bot_id: bot_id, data: %{user: bot_id}}, _bot), do: :halt
  @impl true
  def call(event, _bot), do: event
end
