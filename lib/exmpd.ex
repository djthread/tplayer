defmodule ExMpd do
  import ExMpd.Pool

  require Logger

  # @worker __MODULE__.Worker

  # def state,         do: GenServer.call @worker, :state
  # def raw(command),  do: GenServer.call @worker, {:command, command}
  # def call(command), do: GenServer.call @worker, command
  # def cast(command), do: GenServer.cast @worker, command

  # def call(command), do: call command
  # def cast(message), do: cast message

  defpool call(pid, command) when pid |> is_pid do
    Logger.debug "Calling(#{inspect pid}): #{inspect command}"
    GenServer.call pid, command
  end

  defpool cast(pid, message) when pid |> is_pid do
    Logger.debug "Casting(#{inspect pid}): #{inspect message}"
    IO.inspect pid
    IO.inspect message
    GenServer.cast pid, message
    {:ok, :right}
  end

end
