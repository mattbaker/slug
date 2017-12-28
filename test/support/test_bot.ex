defmodule ExBot.Test.Support.TestBot do
  alias ExBot.Event

  def example_function_slug(event) do
    send(self(), :example_function_slug)
    event |> Event.add_metadata(:example_function_slug, true)
  end
end
