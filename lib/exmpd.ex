defmodule ExMpd do
  use Application

  alias ExMpd.Config

  @worker ExMpd.Worker

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      worker(@worker, [%Config{host: "mobius.threadbox.net"}]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExMpd.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def call inputs do
    GenServer.call @worker, inputs
  end
end
