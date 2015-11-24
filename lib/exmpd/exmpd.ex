defmodule ExMpd do
  import ExMpd.Pool

  require Logger

  @worker __MODULE__.Worker

  def state,         do: GenServer.call @worker, :state
  def raw(command),  do: GenServer.call @worker, {:command, command}
  # def call(command), do: GenServer.call @worker, command
  def cast(command), do: GenServer.cast @worker, command

  defpool call(pid, command) when pid |> is_pid do
    Logger.debug "calling(#{pid}): #{command}"
    GenServer.call pid, command
  end
end
