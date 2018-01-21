defmodule Slug.Common.MessagesOnlyTest do
  use ExUnit.Case
  doctest Slug.Common.MessagesOnly
  alias Slug.Common.MessagesOnly
  alias Slug.Event

  test "allows events of type message" do
    result =
      %Event{bot_id: "UTEST", data: %{type: "message", user: "foo", text: "foo"}}
      |> MessagesOnly.call(:fake_bot)

    refute result == :halt
  end

  test "disallows events that are not messages" do
    result =
      %Event{bot_id: "UTEST", data: %{type: "hello"}}
      |> MessagesOnly.call(:fake_bot)

    assert result == :halt
  end
end
