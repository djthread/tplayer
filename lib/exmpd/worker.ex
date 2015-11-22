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
    Logger.info "Connecting to #{config.host}:#{config.port}..."
    socket  = connect! config.host, config.port
    version = socket |> recv! |> motd_to_version
    state   = %State{config: config, socket: socket, version: version}
    Logger.info "Connected to MPD (#{version})"
    Logger.debug "ExMpd State: " <> inspect state

    {:ok, state}
  end

  def handle_call(:state, _from, state = %State{}) do
    {:reply, state, state}
  end
  def handle_call({:call, command}, _from, state = %State{socket: socket}) do
    socket |> send!(command)
    {:reply, socket |> recv_lines_till_ok!, state}
  end
  def handle_call(:status, _from, state = %State{socket: socket}) do
    socket |> send!("status")
    state = socket |> recv! |> parse_status(state)
    {:reply, state, state}
  end
  def handle_call(:play, _from, state = %State{socket: socket}) do
    socket |> send!("play")
    state = socket |> recv_ok!(state)
  end

  def handle_cast({:cast, :refresh}, _from, state = %State{socket: socket}) do
    Logger.debug "Spawning refresher..."
    pid = spawn_link &_refresher/0
    {:noreply, Map.put(state, :refresher, pid)}
  end

  defp _refresher(st = %State{}) do
    socket |> send!(command)
    GenServer.call __MODULE__, :call, [update_state: %State{albums: albums}]
  end
end
