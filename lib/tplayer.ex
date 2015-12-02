defmodule TPlayer do
  use Application

  @exmpd  ExMpd.Worker
  @worker TPlayer.Worker

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # exmpd = worker(@exmpd, [%ExMpd.Config{
    #   host: Application.get_env(:tplayer, :mpd_host),
    #   port: Application.get_env(:tplayer, :mpd_port)
    # }])

    tplayer = worker(@worker, [%TPlayer.Config{
      base_dir: "~/.tplayer",
      modules:  Application.get_env(:tplayer, :modules)
    }])

    # children = [exmpd, tplayer]
    children = [tplayer]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TPlayer.Supervisor]
    Supervisor.start_link children, opts
  end

  # generic calls
  def call(input), do: @worker.call input
  def cast(input), do: @worker.cast input
end

defmodule TP do
  def call(input), do: @worker.call input
  def cast(input), do: @worker.cast input
end
