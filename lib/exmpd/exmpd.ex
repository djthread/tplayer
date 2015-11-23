defmodule ExMpd do
  @worker __MODULE__.Worker

  def state,         do: GenServer.call @worker, :state
  def raw(command),  do: GenServer.call @worker, {:command, command}
  def call(command), do: GenServer.call @worker, command
  def cast(command), do: GenServer.cast @worker, command
end
