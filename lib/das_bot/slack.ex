defmodule DasBot.Slack do
  @moduledoc """
  This module provides access to a few Slack Web API calls, as well as maintaining
  a cache of user and channel information for quick lookups.
  """
  use GenServer
  require Logger

  # Client
  @doc false
  def start_link([]) do
    token = DasBot.get_api_token(:web_api)
    GenServer.start_link(__MODULE__, token, name: __MODULE__)
  end

  @doc false
  @spec init(token :: String.t()) :: {:ok, %{}}
  def init(token) do
    state = %{
      users: fetch_users(token),
      channels: fetch_channels(token),
      token: token
    }

    {:ok, state}
  end

  @doc """
  Requests a [Real Time Messaging session](https://api.slack.com/methods/rtm.connect)
  from Slack. Returns a tuple containing the websocket URL, the id of the bot
  requesting the session, and the name of the bot requesting the session.

  ## Example

  ```
  {url, bot_id, bot_name} = DasBot.Slack.get_rtm_connection("xo-my-token")
  ```
  """
  @spec get_rtm_connection(String.t()) :: {String.t(), String.t(), String.t()}
  def get_rtm_connection(bot_token) do
    %{url: url, self: %{id: id, name: name}} = post("rtm.connect", bot_token)
    {url, id, name}
  end

  @doc """
  Posts a message through the [Slack REST API](https://api.slack.com/methods/chat.postMessage)
  instead of via Websocket.

  Helpful if you need to post a message with fancy formatting, which is not currently supported
  via the RTM API.
  """
  @spec post_message(String.t(), String.t(), String.t(), String.t(), []) :: %{}
  def post_message(token, author, channel, text, attachments \\ []) do
    data = [
      channel: channel,
      text: text,
      as_user: author,
      attachments: attachments |> Poison.encode!()
    ]

    post("chat.postMessage", token, data)
  end

  @doc """
  Get information about the user identified by `user_id`.
  """
  def get_user(user_id) do
    GenServer.call(__MODULE__, {:get_user, user_id})
  end

  @doc """
  Fetch channel information by the channel's ID, ex. "C2147483705".
  """
  @spec get_channel(String.t()) :: %{}
  def get_channel(channel_id) do
    GenServer.call(__MODULE__, {:get_channel, channel_id})
  end

  @doc """
  Fetch channel information by the channel's name, ex. "general".
  """
  @spec get_channel_by_name(String.t()) :: %{}
  def get_channel_by_name(channel_name) do
    GenServer.call(__MODULE__, {:get_channel_by_name, channel_name})
  end

  @doc """
  Add a reaction to a message. The timestamp of the message should be part of the
  message's event.

  ## Example
  ```
  msg = %{
    type: "message",
    channel: "C2147483705",
    user: "U2147483697",
    text: "Hello world",
    ts: "1355517523.000005"
  }
  DasBot.Slack.add_reaction(msg.channel, msg.ts, "thumbsup")
  ```
  """
  @spec add_reaction(String.t(), String.t(), String.t()) :: %{}
  def add_reaction(channel, message_timestamp, reaction) do
    GenServer.call(__MODULE__, {:add_reaction, channel, message_timestamp, reaction})
  end

  # Server
  def handle_call({:get_user, user_id}, _from, %{users: users} = state) do
    {:reply, Map.fetch!(users, user_id), state}
  end

  def handle_call({:get_channel, channel_id}, _from, %{channels: channels} = state) do
    {:reply, Map.fetch!(channels, channel_id), state}
  end

  def handle_call({:get_channel_by_name, channel_name}, _from, %{channels: channels} = state) do
    channels
    |> Map.values()
    |> Enum.find(&match?(%{name: ^channel_name}, &1))
    |> case do
      nil -> {:reply, {:error, "Not Found"}, state}
      channel -> {:reply, channel, state}
    end
  end

  def handle_call({:add_reaction, channel, ts, reaction}, _from, %{token: token} = state) do
    data = [channel: channel, timestamp: ts, name: reaction]
    {:reply, post("reactions.add", token, data), state}
  end

  defp fetch_users(token) do
    post("users.list", token, presence: false)
    |> Map.fetch!(:members)
    |> Enum.reduce(%{}, &Map.put(&2, &1[:id], &1))
  end

  defp fetch_channels(token) do
    post("channels.list", token, exclude_members: true)
    |> Map.fetch!(:channels)
    |> Enum.reduce(%{}, &Map.put(&2, &1[:id], &1))
  end

  defp post(endpoint, token, opts \\ []) do
    form_data = Keyword.merge([token: token], opts)

    {:ok, response} =
      HTTPoison.post("https://slack.com/api/#{endpoint}", {:form, form_data})
      |> extract_response

    response
  end

  defp extract_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    case Poison.decode!(body, keys: :atoms) do
      %{ok: true} = payload -> {:ok, payload}
      response -> {:error, "Unexpected JSON response: #{inspect(response)}"}
    end
  end

  defp extract_response({:ok, %HTTPoison.Response{status_code: status}}) do
    {:error, "Non-200 response from Slack API: #{status}"}
  end

  defp extract_response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end
end
