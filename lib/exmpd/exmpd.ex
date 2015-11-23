defmodule ExMpd do
  use GenServer

  @worker __MODULE__.Worker

  @doc ~S/Update and return the current status/
  def status, do: GenServer.call @worker, :status

  def state,         do: GenServer.call @worker, :state
  def call(command), do: GenServer.call @worker, {:call, command}
  def cast(command), do: GenServer.cast @worker, command
end
