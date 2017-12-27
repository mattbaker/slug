defmodule DasBot.Slack do
  use GenServer
  require Logger

  # Client
  def start_link(token: token) do
    GenServer.start_link(__MODULE__, token, name: __MODULE__)
  end

  def init(token) do
    state = %{
      users: fetch_users(token),
      channels: fetch_channels(token),
      token: token
    }

    {:ok, state}
  end

  def get_rtm_connection(bot_token) do
    GenServer.call(__MODULE__, {:get_rtm_connection, bot_token})
  end

  def get_user(user_id) do
    GenServer.call(__MODULE__, {:get_user, user_id})
  end

  def get_channel(channel_id) do
    GenServer.call(__MODULE__, {:get_channel, channel_id})
  end

  def get_channel_by_name(channel_name) do
    GenServer.call(__MODULE__, {:get_channel_by_name, channel_name})
  end

  def add_reaction(channel, ts, reaction) do
    GenServer.call(__MODULE__, {:add_reaction, channel, ts, reaction})
  end

  # Server
  def handle_call({:get_rtm_connection, bot_token}, _from, state) do
    {:reply, rtm_connect(bot_token), state}
  end

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

  def post_message(token, author, channel, text, attachments \\ []) do
    data = [
      channel: channel,
      text: text,
      as_user: author,
      attachments: attachments |> Poison.encode!()
    ]

    post("chat.postMessage", token, data)
  end

  defp rtm_connect(token) do
    %{url: url, self: %{id: id, name: name}} = post("rtm.connect", token)
    {url, id, name}
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
