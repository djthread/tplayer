defmodule TPlayer.Util do
  def fix_path(path = "/" <> _, _base), do: path
  def fix_path(path, base),             do: Path.expand(path, base)
end
