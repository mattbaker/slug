defmodule DasBot.Test.Support.TestBot do
  alias DasBot.Event

  def example_function_slug(event) do
    send(self(), :example_function_slug)
    event |> Event.add_metadata(:example_function_slug, true)
  end
end
