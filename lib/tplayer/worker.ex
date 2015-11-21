defmodule TPlayer.Worker do
  use GenServer

  require Logger

  alias TPlayer.Config
  alias TPlayer.State

  @doc ~S/Start TPlayer app/
  def start_link(config = %Config{} \\ %Config{}) do
    {:ok, _} = GenServer.start_link __MODULE__, config, name: __MODULE__
  end

  @doc ~S/Dispatch a request/
  def call(req), do: GenServer.call __MODULE__, :call, [req]


  ## GenServer Implementation
  #

  def init(config = %Config{}) do

    # Normalize the config
    config = config
    |> Map.put(:base_dir, _fix_path(config.base_dir, "/"))
    |> Map.put(:cache_dir, _fix_path(config.cache_dir, config.base_dir))

    # Make sure the dirs exist
    [config.base_dir, config.cache_dir] |> Enum.each &File.mkdir_p!/1

    # Run module init routines
    st = Enum.reduce config.modules,
                     %State{config: config},
                     fn m, acc -> m.init(acc) end

    Logger.debug "State: " <> inspect st

    {:ok, st}
  end

  @doc ~S/Invoke an action. We'll figure out which module it's for./
  def handle_call(:state, _from, st = %State{}), do: {:reply, st, st}
  def handle_call(req, _from, st = %State{}) when is_atom(req) or is_tuple(req) do
    _call req, st.config.modules, st
  end

  defp _call(req, [module | tail], st = %State{}) do
    try do
      module.call req, st
    rescue
      _ in [FunctionClauseError, UndefinedFunctionError] ->
        _call req, tail, st
    end
  end
  defp _call(req, [], _), do: {:error, "No handler found for: " <> inspect(req)}

  defp _fix_path(path = "/" <> _, _base), do: path
  defp _fix_path(path, base),             do: Path.expand(path, base)

end
