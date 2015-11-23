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

  def handle_cast({:refresh, cb}, st = %State{}) do
    Logger.debug "Spawning refresher..."
    spawn_link fn ->
      _new_conn_get_albums st, cb
    end
    {:noreply, st}
  end

  @doc ~S/With a new MPD connection, fetch a list of all the albums/
  defp _new_conn_get_albums(%State{config: conf}, cb) when is_function(cb) do
    {socket, _version} = create_mpd_conn conf.host, conf.port
    socket |> send!("list album")
    socket
    |> recv_lines_till_ok!
    # |> Enum.map(&String.trim_prefix(&1, "Album: "))  # waiting for 1.2
    |> Enum.map(fn(a) ->
                  case Regex.run(~r/^Album: (.*)$/, a) do
                    [_, a] -> a
                    _      -> ""
                  end
               end)
    |> Enum.filter(&(&1 != ""))
    |> cb.()
  end
end
