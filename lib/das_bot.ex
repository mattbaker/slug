defmodule DasBot do
  @moduledoc """
  Documentation for DasBot.
  """

  def get_env(key) do
    Application.get_env(:das_bot, key)
  end
end
