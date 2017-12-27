defmodule DasBot.Slug.Common.FilterSelfTest do
  use ExUnit.Case
  doctest DasBot.Slug.Common.FilterSelf
  alias DasBot.Slug.Common.FilterSelf
  alias DasBot.Slug.Event

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
