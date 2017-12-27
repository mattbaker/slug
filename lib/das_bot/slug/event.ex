defmodule DasBot.Slug.Event do
  @enforce_keys [:bot_id, :data]
  defstruct [:bot_id, :data, {:metadata, %{}}]

  alias DasBot.Slug.Event

  def add_metadata(%Event{metadata: metadata} = event, data) when is_map(data) do
    %{event | metadata: metadata |> Map.merge(data)}
  end

  def add_metadata(%Event{metadata: metadata} = event, key, value) do
    %{event | metadata: metadata |> Map.put(key, value)}
  end
end
