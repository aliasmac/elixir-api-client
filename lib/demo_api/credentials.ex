defmodule Credentials do
  use Agent

  # https://stackoverflow.com/questions/50168264/how-do-you-communicate-with-an-elixir-agent-from-within-a-phoenix-controller

  @name {:global, __MODULE__}

  @doc """
  Starts a new bucket.
  """
  def start_link do
    # __MODULE__ here would be HelloBlockchain.Monitor
    Agent.start_link(fn -> %{} end, name: @name)
  end

  def start_link([]) do
    Agent.start_link(fn -> %{} end, name: @name)
  end

  @doc """
  Gets a value from the `bucket` by `key`.
  """
  def get(key) do
    Agent.get(@name, &Map.get(&1, key))
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  def add(key, value) do
    Agent.update(@name, &Map.put(&1, key, value))
  end

  def reset do
    Agent.update(@name, fn _state -> %{} end)
  end

  def getKeys() do
    Agent.get(@name, fn state ->
      Map.keys(state)
    end)
  end
end