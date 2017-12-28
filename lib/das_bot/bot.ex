defmodule DasBot.Bot do
  @moduledoc """
  This module can be `use`-d into a module in order to define a Slack bot.
  It also includes functions for sending messages and events from a bot to
  a slack channel.
  """
  @callback on_connect(state :: state) :: {atom, state}
  @optional_callbacks on_connect: 1

  @typedoc false
  @type t :: module()

  @typedoc false
  @type state :: %{atom => any()}

  alias DasBot.Slack

  @doc """
  Sends a message from a bot to a channel, identified by name.

  ## Example

  ```
  DasBot.Bot.send_to_channel(MyBot, "general", "Hello world")
  ```
  """
  @spec send_to_channel(t(), String.t(), String.t()) :: any()
  def send_to_channel(bot, channel_name, msg) do
    %{id: cid} = Slack.get_channel_by_name(channel_name)
    send_text(bot, cid, msg)
  end

  @doc """
  Sends a message from a bot to a channel, identified by id.

  ## Example

  ```
  DasBot.Bot.send_text(MyBot, "C0G9QF9GW", "Hello world")
  ```
  """
  @spec send_text(t(), String.t(), String.t()) :: any()
  def send_text(bot, channel_id, text) do
    send_event(bot, %{type: "message", channel: channel_id, text: text})
  end

  @doc """
  Sends an arbitrary JSON payload to Slack from a bot.

  ## Example

  ```
  DasBot.Bot.send_event(MyBot, %{type: "message", channel: "C0G9QF9GW", text: "Hello world"})
  ```
  """
  @spec send_event(t(), %{atom => any()}) :: any()
  def send_event(bot, event) do
    cast(bot, {:text, Poison.encode!(event)})
  end

  defp cast(bot, msg) do
    Process.whereis(bot)
    |> :websocket_client.cast(msg)
  end

  defmacro __using__(_params) do
    quote do
      require Logger
      use DasBot.Slug.PipelineBuilder

      @behaviour DasBot.Bot
      @behaviour :websocket_client
      @keepalive 10_000

      # Client
      def start_link() do
        DasBot.get_api_token(__MODULE__)
        |> start_websocket(!!System.get_env("NO_BOT_START"))
      end

      defp start_websocket(bot_token, false) do
        Logger.info("#{__MODULE__}: Initializing Websocket")

        {url, bot_id, bot_name} = Slack.get_rtm_connection(bot_token)
        initial_state = %{bot_id: bot_id, bot_name: bot_name}

        {:ok, pid} =
          :websocket_client.start_link(url, __MODULE__, initial_state, keepalive: @keepalive)

        Process.register(pid, __MODULE__)
        {:ok, pid}
      end

      defp start_websocket(bot_token, true), do: :ignore

      def child_spec(opts) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, opts},
          restart: :permanent,
          shutdown: 5000,
          type: :worker
        }
      end

      # Server
      def init(state), do: {:reconnect, state}

      def onconnect(_wsreq, state), do: on_connect(state)

      def websocket_info(_, _, state), do: {:ok, state}

      def websocket_handle({:text, json}, _, state) do
        Poison.decode!(json, keys: :atoms)
        |> on_event(state)
      end

      def websocket_handle(_msg, _from, state), do: {:ok, state}

      def ondisconnect({:error, :keepalive_timeout}, state) do
        Logger.warn("#{__MODULE__}: Keepalive timeout, attempting reconnect")
        {:reconnect, state}
      end

      def ondisconnect({:remote, :closed}, state) do
        Logger.warn("#{__MODULE__}: Socket closed, attempting reconnect")
        {:reconnect, state}
      end

      def ondisconnect(reason, state) do
        Logger.warn("#{__MODULE__}: Socket disconnected: #{inspect(reason)}")
        {:close, reason, state}
      end

      def websocket_terminate(reason, _, state) do
        Logger.warn("#{__MODULE__}: Socket terminated: #{inspect(reason)}")
        :ok
      end

      def on_connect(state), do: {:ok, state}
      defoverridable on_connect: 1
    end
  end
end
