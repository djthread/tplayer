defmodule TPlayer.Modules.Core do
  alias TPlayer.State

  def call_state(st = %State{}) do
    {:reply, st, st}
  end

  def cast_merge_state(a) do
    IO.puts "AA" <> inspect a
  end
  def cast_merge_state(a, b) do
    IO.puts "BB" <> inspect a
  end
  def cast_merge_state(a, b, c) do
    IO.puts "CC" <> inspect a
  end
  def cast_merge_state(new_state = %{}, st = %State{}) do
    {:noreply, st |> Map.merge(new_state)}
  end

end
