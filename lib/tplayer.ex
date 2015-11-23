defmodule TPlayer do
  use Application

  @exmpd   ExMpd.Worker
  @tplayer TPlayer.Worker
  # @host    "mobius.threadbox.net"
  @host    "localhost"

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    exmpd = worker(@exmpd, [%ExMpd.Config{
      host: @host
    }])

    tplayer = worker(@tplayer, [%TPlayer.Config{
      base_dir: "~/.tplayer",
      modules:  Application.get_env(:tplayer, :modules)
    }])

    children = [exmpd, tplayer]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TPlayer.Supervisor]
    Supervisor.start_link children, opts
  end

  # calls
  def state,        do: GenServer.call @tplayer, :state

  # casts
  def refresh,      do: GenServer.cast @tplayer, :refresh

  # generic calls
  def call(inputs), do: GenServer.call @tplayer, inputs
  def cast(inputs), do: GenServer.cast @tplayer, inputs
end
