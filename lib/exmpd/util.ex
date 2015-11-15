defmodule ExMpd.Util do
  require Socket

  alias ExMpd.State

  @status_fields ~w(volume repeat random single consume playlist
                    playlistlength mixrampdb state)

  def connect!(uri),      do: Socket.connect!      uri
  def recv!(socket),      do: Socket.Stream.recv!  socket
  def send!(socket, msg), do: Socket.Stream.send!  socket, "#{msg}\n"

  def motd_to_version(motd) do
    %{"ver" => ver} = Regex.named_captures ~r/OK MPD (?<ver>[\d\.]+)\n/, motd
    ver
  end

  def parse_status(str, state = %State{}) when is_binary(str) do
    str |> String.split("\n") |> parse_status(state)
  end
  for field <- @status_fields do
    def parse_status([head = unquote(field) <> ": " <> val | tail],
                     state = %State{}) do
      IO.puts "HI"
      IO.inspect head
      [k, v] = Regex.run ~r/^(\w): (.+)$/, head

      IO.inspect k
      IO.inspect v
      state = Map.put(state, String.to_atom(k), v)
      parse_status(tail, state)
    end
  end
  def parse_status("volume: " <> left, state = %State{}) do

  end
  def parse_status(x, state = %State{}) do
  end
end
