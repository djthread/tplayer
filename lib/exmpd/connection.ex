defmodule ExMpd.Connection do
  use GenServer

  require Logger
  require Socket

  def start_link(host, port) when port |> is_integer do
    Logger.debug "GenServer.start_link..."
    {:ok, _} = GenServer.start_link(__MODULE__, [host, port])
  end

  def connect!(host, port), do: Socket.TCP.connect! host, port#, packet: :line
  def recv!(socket),        do: Socket.Stream.recv! socket
  def send!(socket, msg),   do: Socket.Stream.send! socket, "#{msg}\n"


  ## GenServer Implementation
  #
  def init([host, port]) when port |> is_integer do
    Logger.debug "Connecting to #{host}:#{port}..."
    socket  = connect!(host, port)
    get_ver = fn(motd) ->
      [_, ver] = Regex.run ~r/OK MPD ([\d\.]+)\n/, motd
      ver
    end
    version = socket |> recv! |> get_ver.()
    Logger.info "Connected to MPD at #{host}:#{port} (#{version})"
    {:ok, socket}
  end

  def handle_call({:command, command}, _from, socket) do
    socket |> send!(command)
    {:reply, socket |> recv_lines_till_ok!, socket}
  end


  ## Additional Things & Stuff
  #

  defp recv_lines_till_ok!(socket) do
    _recv_lines_till_ok! socket, recv!(socket), "", []
  end
  defp _recv_lines_till_ok!(socket, cur, acc, albums) do
    acc = acc <> cur
    if String.ends_with?(acc, "\nOK\n") do
      acc |> String.split("\n")
    else
      _recv_lines_till_ok! socket, recv!(socket), acc, albums
    end
  end

  # def recv_ok!(socket, state) do
  #   "OK\n" = Socket.Stream.recv!(socket, state)
  # end

end
