defmodule TPlayer.Modules.Core do
  alias TPlayer.State

  def call(:state, st = %State{}) do
    {:reply, st, st}
  end

  def cast({:merge_state, state = %{}}, st = %State{}) do
    {:noreply, st |> Map.merge(state)}
  end

end
