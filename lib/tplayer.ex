defmodule TPlayer do
  use Application

  @exmpd   ExMpd.Worker
  @tplayer TPlayer.Worker
  @host    "localhost"

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(type, args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      worker(@exmpd, [%ExMpd.Config{
        host: (args[:host] || @host)
      }]),
      worker(@tplayer, [%TPlayer.Config{}])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TPlayer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def call inputs do
    GenServer.call @worker, inputs
  end
end
