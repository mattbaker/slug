defmodule DasBot.Slug do
  alias DasBot.Slug.Event
  @callback call(%Event{}, module()) :: %Event{} | :halt
end
