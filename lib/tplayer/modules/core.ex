defmodule TPlayer.Modules.Core do
  use GenServer

  alias TPlayer.State

  def init(st = %State{}) do
    st
  end

  def call(:state, st = %State{}) do
    {:reply, st, st}
  end

  def cast({:merge_state, state = %{}}, st = %State{}) do
    {:noreply, st |> Map.merge(state)}
  end

end
