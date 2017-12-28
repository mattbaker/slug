defmodule DasBot.EventTest do
  use ExUnit.Case
  doctest DasBot.Event
  alias DasBot.Event

  describe "add_metadata" do
    test "attaches k-v pairs" do
      event =
        %Event{bot_id: "foo", data: %{}}
        |> Event.add_metadata(:foo, "bar")
        |> Event.add_metadata(:baz, "bang")

      assert event == %Event{
               bot_id: "foo",
               data: %{},
               metadata: %{foo: "bar", baz: "bang"}
             }
    end

    test "merges data" do
      event =
        %Event{bot_id: "foo", data: %{}}
        |> Event.add_metadata(%{foo: "bar", baz: "bang"})

      assert event == %Event{
               bot_id: "foo",
               data: %{},
               metadata: %{foo: "bar", baz: "bang"}
             }
    end
  end
end
