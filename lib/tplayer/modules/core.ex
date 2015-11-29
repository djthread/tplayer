defmodule TPlayer.Modules.Core do
  alias TPlayer.State

  def call_state(st = %State{}) do
    {:reply, st, st}
  end

  def cast_merge_state(new_state = %{}, st = %State{}) do
    {:noreply, st |> Map.merge(new_state)}
  end

end
