defmodule TPlayer.Worker do
  use GenServer

  alias TPlayer.Config
  alias TPlayer.State

  @doc ~S/Start TPlayer app/
  def start_link(config = %Config{} \\ %Config{}) do
    {:ok, _} = GenServer.start_link __MODULE__, config, name: __MODULE__
  end

  @doc ~S/Dispatch a request/
  def call(req), do: GenServer.call __MODULE__, :call


  ## GenServer Implementation
  #

  def init(config = %Config{}) do
    state = %State{config: config}

    {:ok, state}
  end

  @doc ~S/Invoke an action. We'll figure out which module it's for./
  def handle_call(req, _from, config = %Config{}) when is_atom(req) or is_tuple(req) do
    _call req, Application.get_env(:tplayer, :modules)
  end

  defp _call(req, [module | tail]) do
    try do
      module.call req
    rescue
      x in [FunctionClauseError, UndefinedFunctionError] ->
        _call req, tail
    end
  end
  defp _call(req, []) do
    {:error, "No handler found for: " <> inspect(req)}
  end
end
