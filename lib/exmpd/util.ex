defmodule ExMpd.Util do
  require Socket
  require Logger

  alias ExMpd.State

  def connect!(host, port), do: Socket.TCP.connect! host, port#, packet: :line
  def recv!(socket),        do: Socket.Stream.recv! socket
  def send!(socket, msg),   do: Socket.Stream.send! socket, "#{msg}\n"

  def recv_lines_till_ok!(socket) do
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

  def recv_ok!(socket, state) do
    "OK\n" = Socket.Stream.recv!(socket, state)
  end

  def motd_to_version(motd) do
    %{"ver" => ver} = Regex.named_captures ~r/OK MPD (?<ver>[\d\.]+)\n/, motd
    ver
  end

  def create_mpd_conn(host, port) do
    Logger.info "Connecting to #{host}:#{port}..."
    socket  = connect! host, port
    version = socket |> recv! |> motd_to_version
    Logger.info "Connected to MPD (#{version})"
    {socket, version}
  end

  @doc ~S/Turn the status string from mpd into an updated state object./
  def parse_status(str, state = %State{}) when is_binary(str) do
    str |> String.split("\n") |> parse_status(state)
  end
  def parse_status([head | tail], state = %State{}) do
    m = Regex.run(~r/^(\w+): (.+)$/, head)
    if !is_nil(m) && ([_, k, v] = m) do
      state = Map.put state, String.to_atom(k), v
    end
    parse_status tail, state
  end
  def parse_status(_, state = %State{}) do
    state
  end
end
