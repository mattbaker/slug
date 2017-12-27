defmodule DasBot.Test.Support.TestBot do
  alias DasBot.Slug.Event

  def example_function_slug(event) do
    send(self(), :example_function_slug)
    event |> Event.add_metadata(:example_function_slug, true)
  end

  # def send_to_channel(channel, text) do
  #   send(self(), {:send_to_channel, channel, text})
  # end

  # def send_text(channel_id, text) do
  #   send(self(), {:send_text, channel_id, text})
  # end
end
