defmodule ExMpd.Worker do
  @moduledoc ~S/Control all the MPD things!/
  use GenServer

  require Logger

  import ExMpd.Util

  alias ExMpd.Config
  alias ExMpd.State

  @doc ~S/Start an MPD client instance/
  def start_link(config = %Config{} \\ %Config{}) do
    {:ok, _} = GenServer.start_link __MODULE__, config, name: __MODULE__
  end

  @doc ~S/Update and return the current status/
  def status(), do: GenServer.call __MODULE__, :status


  ## GenServer Implementation
  #

  def init(config = %Config{}) do
    Logger.info "Connecting to #{config.host}:#{config.port}..."
    uri     = %URI{scheme: "tcp", host: config.host, port: config.port}
    socket  = uri    |> connect! 
    version = socket |>    recv! |> motd_to_version
    state   = %State{config: config, socket: socket, version: version}
    Logger.info "Connected to MPD (#{version})"

    {:ok, state}
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

end
