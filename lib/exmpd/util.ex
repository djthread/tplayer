defmodule ExMpd.Util do
  require Socket
  require Logger

  alias ExMpd.State

  @doc ~S/Turn the status string from mpd into an updated state object./
  def parse_status(str, state = %State{}) when is_binary(str) do
    str |> String.split("\n") |> parse_status(state)
  end
  def parse_status([head | tail], state = %State{}) do
    m = Regex.run ~r/^(\w+): (.+)$/, head
    if !is_nil(m) && ([_, k, v] = m) do
      state = Map.put state, String.to_atom(k), v
    end
    parse_status tail, state
  end
  def parse_status(_, state = %State{}) do
    state
  end
end
