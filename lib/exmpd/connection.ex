defmodule ExMpd.Connection do
  use GenServer

  def start_link(id) when id |> is_atom do
    GenServer.start_link id, TPlayer.state.config
  end
end
