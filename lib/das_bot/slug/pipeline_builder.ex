defmodule DasBot.Slug.PipelineBuilder do
  @type slug :: module | atom
  alias DasBot.Slug.Event

  defmacro __using__(_params) do
    quote do
      import DasBot.Slug.PipelineBuilder, only: [slug: 1, execute_pipeline: 3]

      Module.register_attribute(__MODULE__, :slugs, accumulate: true)

      @before_compile DasBot.Slug.PipelineBuilder
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def on_event(data, %{bot_id: bot_id, bot_name: bot_name} = state) do
        initial_event = %Event{bot_id: bot_id, data: data, metadata: %{bot_name: bot_name}}

        @slugs
        |> Enum.reverse()
        |> execute_pipeline(initial_event, __MODULE__)

        {:ok, state}
      end
    end
  end

  defmacro slug(slug) do
    quote do
      @slugs unquote(slug)
    end
  end

  def execute_pipeline(slugs, initial_event, bot_module) do
    Enum.reduce_while(slugs, initial_event, fn slug, current_event ->
      case execute_slug(slug, current_event, bot_module) do
        :halt -> {:halt, current_event}
        event -> {:cont, event}
      end
    end)
  end

  defp execute_slug(slug, event, bot_module) do
    case Atom.to_charlist(slug) do
      ~c"Elixir." ++ _ -> slug.call(event, bot_module)
      _ -> apply(bot_module, slug, [event])
    end
  end
end
