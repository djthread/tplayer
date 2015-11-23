defmodule ExMpd.Worker do
  @moduledoc ~S/Control all the MPD things!/

  require Logger

  import ExMpd.Util

  alias ExMpd.Config
  alias ExMpd.State

  @doc ~S/Start an MPD client instance/
  def start_link(config = %Config{} \\ %Config{}) do
    {:ok, _} = GenServer.start_link __MODULE__, config, name: __MODULE__
  end

  ## GenServer Implementation
  #

  def init(config = %Config{}) do
    {socket, version} = create_mpd_conn config.host, config.port
    st = %State{config: config, socket: socket, version: version}

    Logger.debug "ExMpd State: " <> inspect st

    {:ok, st}
  end

  def handle_call(:state, _from, st = %State{}) do
    {:reply, st, st}
  end
  def handle_call({:call, command}, _from, st = %State{socket: socket}) do
    socket |> send!(command)
    {:reply, socket |> recv_lines_till_ok!, st}
  end
  def handle_call(:status, _from, st = %State{socket: socket}) do
    socket |> send!("status")
    st = socket |> recv! |> parse_status(st)
    {:reply, st, st}
  end
  def handle_call(:play, _from, st = %State{socket: socket}) do
    socket |> send!("play")
    st = socket |> recv_ok!(st)
  end

  def handle_cast({:refresh, func}, st = %State{}) do
    Logger.debug "Spawning refresher..."
    spawn_link fn -> _refresher st, func end
    {:noreply, st}
  end

  defp _refresher(%State{config: conf}, func) when is_function(func) do
    {socket, _version} = create_mpd_conn conf.host, conf.port
    socket |> send!("list album")
    albums = socket |> recv_lines_till_ok!
    func.(albums);
    # GenServer.call __MODULE__, :call, [update_state: %State{albums: albums}]
  end
end
