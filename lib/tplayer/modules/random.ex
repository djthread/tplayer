defmodule TPlayer.Modules.Random do
  alias TPlayer.State

  require Logger

  def init(st = %State{}) do
    :random.seed(:erlang.now)
    st
  end

  def call_random_tracks(number, st = %State{})
  when is_integer(number) do
    tracks = get_random_tracks number, [], st
    {:reply, tracks, st}
  end


  ##
  #

  defp get_random_tracks(_number, _acc, %State{albums: albums})
  when length(albums) == 0 do
    nil
  end
  defp get_random_tracks(number, acc, %State{albums: albums}) do
    random_album = Enum.random(albums)
    tracks       = ExMpd.call {:find_album, random_album}
    Logger.info tracks
    2
  end

end
