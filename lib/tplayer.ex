defmodule TPlayer do
  use Application

  @exmpd   ExMpd.Worker
  @tplayer TPlayer.Worker
  @host    "mobius.threadbox.net"

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    exmpd = worker(@exmpd, [%ExMpd.Config{
      host: @host
    }])

    children = [
      exmpd,
      worker(@tplayer, [%TPlayer.Config{
        base_dir: "~/.tplayer",
        modules:  Application.get_env(:tplayer, :modules)
      }])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TPlayer.Supervisor]
    Supervisor.start_link children, opts
  end

  def state,        do: GenServer.call @tplayer, :state
  def call(inputs), do: GenServer.call @tplayer, inputs
end
