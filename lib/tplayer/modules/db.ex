defmodule TPlayer.Modules.Db do

  alias TPlayer.Config

  def init do
    {:ok, %Config{
      cache_dir: Path.expand("~") <> "/.tplayer/cache"
    }}
  end

  def call(:refresh, conf = %Config{}) do
    File.mkdir_p!(conf.cache_dir)
  end
end
