defmodule DasBot.Slug.Common.Peek do
  require Logger
  @behaviour DasBot.Slug

  def call(event, bot) do
    Logger.info("Taking a peek at #{inspect(bot)}...")
    Logger.info(inspect(event))
    event
  end
end
