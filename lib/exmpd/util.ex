defmodule ExMpd.Util do
  require Socket

  alias ExMpd.State

  @status_fields ~w(volume repeat random single consume playlist
                    playlistlength mixrampdb state)

  def connect!(uri),      do: Socket.connect!      uri
  def recv!(socket),      do: Socket.Stream.recv!  socket
  def send!(socket, msg), do: Socket.Stream.send!  socket, "#{msg}\n"

  def recv_ok!(socket, state) do
    "OK\n" = Socket.Stream.recv!(socket, state)
  end

  def motd_to_version(motd) do
    %{"ver" => ver} = Regex.named_captures ~r/OK MPD (?<ver>[\d\.]+)\n/, motd
    ver
  end

  @doc ~S/Turn the status string from mpd into an updated state object/
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
