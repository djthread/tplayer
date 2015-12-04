defmodule TPlayer.Worker do
  use     GenServer
  require Logger
  alias   TPlayer.Config
  alias   TPlayer.State

  @doc ~S/Start TPlayer app/
  def start_link() do
    {:ok, _} = GenServer.start_link __MODULE__, [], name: __MODULE__
  end

  @doc ~S/Dispatch a call request/
  def call(req), do: GenServer.call __MODULE__, req

  @doc ~S/Dispatch a cast/
  def cast(msg), do: GenServer.cast __MODULE__, msg


  ## GenServer Implementation
  #

  def init(_) do
    # Run module init routines, pipelining the state through
    st = Enum.reduce TPlayer.modules,
                     %State{},
                     fn(m, acc) ->
                       case {:init, 1} in m.__info__(:functions) do
                         true -> m.init(acc)
                         _    -> acc
                       end
                     end

    cast :refresh_albums

    Logger.debug "State: " <> inspect st

    {:ok, st}
  end

  @doc ~S/Invoke an action. We'll figure out which module it's for./
  def handle_call(req, _from, st = %State{}) when is_atom(req) or is_tuple(req) do
    _dispatch :call, req, TPlayer.modules, st
  end
  def handle_cast(msg, st = %State{})        when is_atom(msg) or is_tuple(msg) do
    _dispatch :cast, msg, TPlayer.modules, st
  end

  defp _dispatch(type, input, modules, st = %State{}) do
    to_f_atom = fn(name) -> Atom.to_string(type) <> "_#{name}" |> String.to_atom end
    cond do
      is_atom(input) ->
        [input |> to_f_atom.()]
      is_tuple(input) ->
        list = Tuple.to_list(input)
        [hd(list) |> to_f_atom.() | tl(list)]
    end
    |> _dispatch modules, st
  end
  defp _dispatch([f_atom | params], [mod | tail], st = %State{}) when is_atom(f_atom) do
    if {f_atom, length(params) + 1} in mod.__info__(:functions) do
      Logger.debug "Invoking #{Atom.to_string mod}.#{Atom.to_string f_atom}..."
      apply mod, f_atom, params ++ [st]
    else
      _dispatch [f_atom | params], tail, st
    end
  end
  defp _dispatch([f_atom | params], [], _) do
    {:error, "No method found: " <> Atom.to_string(f_atom) <> " (#{inspect params})"}
  end

end
