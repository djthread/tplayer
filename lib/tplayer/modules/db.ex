defmodule TPlayer.Modules.Db do
  require Logger
  alias   TPlayer.State

  def init(st = %State{}) do
    st
    # IO.inspect(g = st |> _load_albums_from_cache)
    # g
  end

  def cast_refresh_albums(st = %State{}) do
    spawn_link fn ->
      albums = ExMpd.call({:command, "list album"})
               # |> Enum.map(&String.trim_prefix(&1, "Album: "))  # waiting for 1.2
               |> Enum.map(&String.replace(&1, "Album: ", ""))
               |> Enum.filter(&(&1 != ""))

      TPlayer.cast {:merge_state, %{albums: albums}}
      # :ok = File.write! _cache_file(st), Enum.join(albums, "\n")
      Logger.info "Finished album refresh, found #{length(albums)}"
    end
    {:noreply, st}
  end

  # defp _load_albums_from_cache(st = %State{}) do
  #   file          = _cache_file(st)
  #   cache_exists? = File.exists? file
  #
  #   if cache_exists? do
  #     albums = File.read!(file) |> String.split("\n")
  #     Map.put st, :albums, albums
  #   else
  #     st
  #   end
  # end
  #
  # defp _cache_file(st = %State{}) do
  #   st.config.cache_dir <> "/albums"
  # end

end
