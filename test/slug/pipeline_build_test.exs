defmodule DasBot.Slug.PipelineBuilderTest do
  use ExUnit.Case
  doctest DasBot.Slug.PipelineBuilder
  alias DasBot.Slug.Event
  alias DasBot.Slug.PipelineBuilder

  describe "execute_pipeline" do
    test "runs slug pipeline" do
      slugs = [
        create_test_slug(Foo),
        create_test_slug(Bar),
        create_test_slug(Baz),
        :example_function_slug
      ]

      event = PipelineBuilder.execute_pipeline(slugs, test_event(), DasBot.Test.Support.TestBot)

      assert event ==
               test_event(%{Foo => true, Bar => true, Baz => true, :example_function_slug => true})

      assert_receive Foo
      assert_receive Bar
      assert_receive Baz
      assert_receive :example_function_slug
    end

    test "stops pipeline execution on halt" do
      defmodule HaltIt do
        def call(_, _), do: :halt
      end

      slugs = [
        create_test_slug(Foo),
        create_test_slug(Bar),
        HaltIt,
        create_test_slug(Baz)
      ]

      event = PipelineBuilder.execute_pipeline(slugs, test_event(), DasBot.Test.Support.TestBot)

      assert event == test_event(%{Foo => true, Bar => true})

      assert_receive Foo
      assert_receive Bar
      refute_receive Baz
    end
  end

  defp create_test_slug(name) do
    case Code.ensure_compiled?(name) do
      true -> name
      false -> define_slug_module(name)
    end
  end

  defp define_slug_module(name) do
    contents =
      quote do
        def call(event, _bot) do
          send(self(), unquote(name))
          event |> Event.add_metadata(unquote(name), true)
        end
      end

    {:module, modname, _, _} = Module.create(name, contents, Macro.Env.location(__ENV__))
    modname
  end

  defp test_event(meta \\ %{}) do
    %Event{
      bot_id: "UTEST",
      data: %{},
      metadata: Map.merge(meta, %{bot_name: "test"})
    }
  end
end
