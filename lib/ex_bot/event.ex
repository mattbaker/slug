defmodule ExBot.Event do
  @moduledoc """
  This module defines the `ExBot.Event` type, representing a Slack event.

  It also includes functions to add metadata to the `ExBot.Event` so that slugs
  may annotate it as it passes through a slug pipeline.
  """

  @enforce_keys [:bot_id, :data]

  @typedoc """
  The Slack user id of the bot. E.x. `UABCDEF`
  """
  @type bot_id :: String.t()

  @typedoc """
  The original Slack event data.
  """
  @type data :: %{}

  @typedoc """
  Metadata about the event, added by slugs.
  """
  @type metadata :: %{}

  @typedoc false
  @type t :: %__MODULE__{
          bot_id: bot_id,
          data: data,
          metadata: metadata
        }

  defstruct [:bot_id, :data, {:metadata, %{}}]

  alias ExBot.Event

  @doc """
  Merges a Map of data into the `ExBot.Event`'s metadata

  ## Example

  ```
  iex> evt = %ExBot.Event{bot_id: "UTESTBOT", data: %{}}
  %ExBot.Event{bot_id: "UTESTBOT", data: %{}, metadata: %{}}
  iex> ExBot.Event.add_metadata(evt, %{foo: "bar"})
  %ExBot.Event{bot_id: "UTESTBOT", data: %{}, metadata: %{foo: "bar"}}
  ```
  """
  @spec add_metadata(ExBot.Event.t(), %{any() => any()}) :: ExBot.Event.t()
  def add_metadata(%Event{metadata: metadata} = event, data) when is_map(data) do
    %{event | metadata: metadata |> Map.merge(data)}
  end

  @doc """
  Adds a key to the `ExBot.Event`'s metadata

  ## Example

  ```
  iex> evt = %ExBot.Event{bot_id: "UTESTBOT", data: %{}}
  %ExBot.Event{bot_id: "UTESTBOT", data: %{}, metadata: %{}}
  iex> ExBot.Event.add_metadata(evt, :foo, "bar")
  %ExBot.Event{bot_id: "UTESTBOT", data: %{}, metadata: %{foo: "bar"}}
  ```
  """
  @spec add_metadata(ExBot.Event.t(), any(), any()) :: ExBot.Event.t()
  def add_metadata(%Event{metadata: metadata} = event, key, value) do
    %{event | metadata: metadata |> Map.put(key, value)}
  end
end
