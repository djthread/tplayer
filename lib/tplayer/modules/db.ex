defmodule TPlayer.Modules.Db do
  use GenServer

  alias TPlayer.State

  def init(st = %State{}) do
    st
  end

  def cast(:refresh, st = %State{}) do
    pid = _start_refresh_albums st
    {:ok, Map.put(st, :refresher, pid)}
  end

  def 

  defp _start_refresh_albums(st = %State{}) do
  end

  defp _refresh_albums(st = %State{}) do
    file          = st.config.cache_dir <> "/albums"
    cache_exists? = File.exists? file

    albums = if cache_exists? do
      File.read!(file) |> String.split("\n")
    else
      albs = ExMpd.call("list album")
             # |> Enum.map(&String.trim_prefix(&1, "Album: "))  # waiting for 1.2
             |> Enum.map(fn(a) -> [_, a] = Regex.run(~r/^Album: (.*)$/, a); a end)
             |> Enum.filter(&(&1 != ""))
      :ok = File.write! file, Enum.join(albs, "\n")
      albs
    end

    Map.put st, :albums, albums
  end

  defp _album_file do
  end
end
