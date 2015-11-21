defmodule TPlayer.Modules.Db do

  alias TPlayer.State

  def init(st = %State{}) do
    st
  end

  def call(:refresh, st = %State{}) do
    {:ok, st |> _loadAlbums}
  end

  defp _loadAlbums(st = %State{}) do
    file          = st.config.cache_dir <> "/albums"
    cache_exists? = File.exists? file

    albums = if cache_exists? do
      File.read!(file) |> String.split("\n")
    else
      albs = ExMpd.call("list album")
             # |> Enum.map(&String.trim_prefix(&1, "Album: "))  # waiting for 1.2
             |> Enum.map(fn(a) -> [_, a] = Regex.run ~r/^Album: (.*)$/, a; a end)
             |> Enum.filter(&(&1 != ""))
      :ok = File.write! file, Enum.join(albs, "\n")
      albs
    end

    Map.put st, :albums, albums
  end

  defp _album_file do
  end
end
