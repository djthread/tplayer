defmodule ExMpd.Worker do
  @moduledoc ~S/Control all the MPD things!/
  use GenServer

  import ExMpd.Util

  alias ExMpd.Config
  alias ExMpd.State

  @doc ~S/Start an MPD client instance/
  def start_link(opts \\ %Config{}) do
    {:ok, _} = GenServer.start_link __MODULE__, opts, name: __MODULE__
  end

  @doc ~S/Update and return the current status/
  def status(), do: GenServer.call __MODULE__, :status


  ## GenServer Implementation
  #

  def init(conf = %Config{}) do
    uri     = %URI{scheme: "tcp", host: conf.host, port: conf.port}
    socket  = uri    |> connect! 
    version = socket |>    recv! |> motd_to_version
    state   = %State{opts: conf, socket: socket, version: version}

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
