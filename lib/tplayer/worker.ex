defmodule TPlayer.Worker do
  use     GenServer
  import  TPlayer.Util, only: [dispatch: 4]
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
    # Run module init routines, pipelining the state through each
    st = Enum.reduce TPlayer.modules,
                     %State{},
                     fn(m, acc) ->
                       case {:init, 1} in m.__info__(:functions) do
                         true -> m.init(acc)
                         _    -> acc
                       end
                     end

    cast :refresh_albums

    Logger.debug "Init state: " <> inspect st

    {:ok, st}
  end

  @doc ~S/Invoke an action. We'll figure out which module it's for./
  def handle_call(req, _from, st = %State{})
  when is_atom(req) or is_tuple(req) do
    dispatch :call, req, TPlayer.modules, st
  end
  def handle_cast(msg, st = %State{})
  when is_atom(msg) or is_tuple(msg) do
    dispatch :cast, msg, TPlayer.modules, st
  end

end
