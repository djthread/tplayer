defmodule TPlayer.Modules.Db do
  use GenServer

  alias TPlayer.State

  def init(st = %State{}) do
    st |> _load_albums_from_cache
  end

  def cast(:refresh, st = %State{}) do
    ExMpd.cast {
      :refresh,
      fn(albums) ->
        TPlayer.cast {:merge_state, %{albums: albums}}
        :ok = File.write! _cache_file(st), Enum.join(albums, "\n")
      end
    }
    {:noreply, st}
  end

  defp _load_albums_from_cache(st = %State{}) do
    file          = _cache_file(st)
    cache_exists? = File.exists? file

    if cache_exists? do
      albums = File.read!(file) |> String.split("\n")
      Map.put st, :albums, albums
    else
      st
    end
  end

  defp _cache_file(st = %State{}) do
    st.config.cache_dir <> "/albums"
  end

end
