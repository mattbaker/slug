defmodule ExBot.Slug.Common.FilterSelfTest do
  use ExUnit.Case
  doctest ExBot.Slug.Common.FilterSelf
  alias ExBot.Slug.Common.FilterSelf
  alias ExBot.Event

  test "filters events originating from the bot itself" do
    result =
      %Event{bot_id: "UTEST", data: %{type: "message", user: "UTEST", text: "foo"}}
      |> FilterSelf.call(:fake_bot)

    assert result == :halt
  end

  test "disallows events that are not messages" do
    result =
      %Event{bot_id: "UTEST", data: %{type: "message", user: "UOTHER", text: "foo"}}
      |> FilterSelf.call(:fake_bot)

    assert result != :halt
  end
end
