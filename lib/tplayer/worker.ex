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

  defp _dispatch(type, input, modules, st = %State{}) do
    to_f_atom = fn(name) -> Atom.to_string(type) <> "_#{name}" |> String.to_atom end
    cond do
      input |> is_atom  -> [input |> to_f_atom.()]
      input |> is_tuple ->
        list = input |> Tuple.to_list
        [hd(list) |> to_f_atom.() | tl(list)]
    end
    |> _dispatch modules, st
  end
  defp _dispatch([f_atom | params], [mod | tail], st = %State{}) when is_atom(f_atom) do
    # IO.puts(Atom.to_string(mod) <> ":" <> Atom.to_string(f_atom) <> " (#{params |> length})")
    # :functions |> mod.__info__ |> IO.inspect
    if {f_atom, length(params)} in mod.__info__(:functions) do
      Logger.debug "Invoking #{Atom.to_string mod}.#{Atom.to_string f_atom}..."
      apply mod, f_atom, params ++ [st]
    else
      _dispatch [f_atom | params], tail, st
    end
  end
  defp _dispatch([f_atom | params], [], _) do
    {:error, "No method found: " <> Atom.to_string(f_atom) <> " (#{inspect params})"}
  end

  defp _fix_path(path = "/" <> _, _base), do: path
  defp _fix_path(path, base),             do: Path.expand(path, base)

end
