defmodule TPlayer.Modules.Random do
  alias TPlayer.State

  require Logger

  def init(st = %State{}) do
    :random.seed(:erlang.now)
    st
  end

  def call({:random_track, number}, st = %State{}) when number |> is_integer do
    tracks = _get_random_tracks number, [], st

    {:reply, tracks, st}
  end

  def cast({:merge_state, state = %{}}, st = %State{}) do
    {:noreply, st |> Map.merge(state)}
  end

  defp _get_random_tracks(_number, _acc, %State{albums: albums}) when albums |> length == 0 do
    nil
  end
  defp _get_random_tracks(number, acc, %State{albums: albums}) do
    random_album = Enum.random(albums)
    Logger.info random_album
    tracks       = ExMpd.call {:find_album, random_album}
    2
    # Logger.info tracks
  end

end
