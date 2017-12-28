defmodule ExBot do
  @moduledoc false

  @doc false
  def get_env(key) do
    Application.get_env(:ex_bot, key)
  end

  @doc false
  def get_api_token(token_key) do
    get_env(:keys)[token_key]
  end
end
