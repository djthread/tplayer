defmodule TPlayer do
  use    Application
  import TPlayer.Util, only: [fix_path: 2]

  @exmpd  ExMpd.Worker
  @worker TPlayer.Worker

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [worker(@worker, [])]

    opts = [strategy: :one_for_one, name: TPlayer.Supervisor]
    Supervisor.start_link children, opts
  end

  # Convenience calls
  #
  def call(input), do: @worker.call input
  def cast(input), do: @worker.cast input


  # Config stuff
  #
  def conf(key), do: Application.get_env(:tplayer, key)

  def modules, do: conf(:modules) |> Keyword.keys

  def module_config(module) do
    conf(:modules) |> Keyword.get(module)
  end

  def base_dir do
    (conf(:base_dir) || "~/.tplayer") |> fix_path(Path.expand("~"))
  end

  def cache_dir do
    (conf(:cache_dir) || "cache")     |> fix_path(base_dir)
  end
end

defmodule TP do
  def call(input), do: TPlayer.Worker.call input
  def cast(input), do: TPlayer.Worker.cast input

  def ref,         do: TPlayer.cast :refresh_albums
end
