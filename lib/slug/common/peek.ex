defmodule Slug.Common.Peek do
  @moduledoc """
  Helpful for debugging. This slug will inspect the event that is moving through
  the pipeline and log it out with `Logger.info`. The event will not be
  changed.
  """
  require Logger
  @behaviour Slug

  @impl true
  def call(event, bot) do
    Logger.info("Taking a peek at #{inspect(bot)}...")
    Logger.info(inspect(event))
    event
  end
end
