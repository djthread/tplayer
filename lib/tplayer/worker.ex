defmodule TPlayer.Worker do
  use GenServer

  require Logger

  alias TPlayer.Config
  alias TPlayer.State

  @doc ~S/Start TPlayer app/
  def start_link(config = %Config{} \\ %Config{}) do
    {:ok, _} = GenServer.start_link __MODULE__, config, name: __MODULE__
  end

  @doc ~S/Dispatch a call request/
  def call(req), do: GenServer.call __MODULE__, :call, [req]

  @doc ~S/Dispatch a cast/
  def cast(msg), do: GenServer.cast __MODULE__, :call, [msg]

  ## GenServer Implementation
  #

  def init(config = %Config{}) do

    # Normalize the config
    config = config
    |> Map.put(:base_dir,  _fix_path(config.base_dir,  Path.expand("~")))
    |> Map.put(:cache_dir, _fix_path(config.cache_dir, config.base_dir))

    # Make sure the dirs exist
    [config.base_dir, config.cache_dir] |> Enum.each &File.mkdir_p!/1

    # Run module init routines
    st = Enum.reduce config.modules,
                     %State{config: config},
                     fn(m, acc) ->
                       try do
                         m.init(acc)
                       rescue
                         UndefinedFunctionError -> acc
                       end
                     end

    Logger.debug "State: " <> inspect st

    {:ok, st}
  end

  @doc ~S/Invoke an action. We'll figure out which module it's for./
  def handle_call(req, _from, st = %State{}) when is_atom(req) or is_tuple(req) do
    _dispatch :call, req, st.config.modules, st
  end
  def handle_cast(msg, st = %State{}) when is_atom(msg) or is_tuple(msg) do
    _dispatch :cast, msg, st.config.modules, st
  end

  defp _dispatch(type, input, [mod | tail], st = %State{}) do
    try do
      case type do
        :call -> mod.call input, st
        :cast -> mod.cast input, st
      end
    rescue
      _ in [FunctionClauseError, UndefinedFunctionError] ->
        _dispatch type, input, tail, st
    end
  end
  defp _dispatch(type, input, [], _) do
    {:error, "No " <> Atom.to_string(type)
          <> " handler found for: " <> inspect(input)
    }
  end

  defp _fix_path(path = "/" <> _, _base), do: path
  defp _fix_path(path, base),             do: Path.expand(path, base)

end
