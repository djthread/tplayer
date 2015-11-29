defmodule TPlayer do
  use Application

  @exmpd   ExMpd.Worker
  @tplayer TPlayer.Worker

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # exmpd = worker(@exmpd, [%ExMpd.Config{
    #   host: Application.get_env(:tplayer, :mpd_host),
    #   port: Application.get_env(:tplayer, :mpd_port)
    # }])

    tplayer = worker(@tplayer, [%TPlayer.Config{
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

  # calls
  def state,        do: GenServer.call @tplayer, :state

  # casts
  def refresh,      do: GenServer.cast @tplayer, :refresh_albums

  # generic calls
  def call(inputs), do: GenServer.call @tplayer, inputs
  def cast(inputs), do: GenServer.cast @tplayer, inputs
end

defmodule TP do
  def ref,          do: TP.refresh
  def refresh,      do: TPlayer.refresh
  def cast(inputs), do: TPlayer.cast inputs
end
