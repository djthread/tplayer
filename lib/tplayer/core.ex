defmodule TPlayer.Core do
  def call(req) when is_atom(req) or is_tuple(req) do
    _call req, Application.get_env(:tplayer, :modules)
  end

  defp _call(req, [module | tail]) do
    try do
      module.call req
    rescue
      x in [FunctionClauseError, UndefinedFunctionError] -> _call req, tail
    end
  end
  defp _call(req, []) do
    {:error, "No handler found for: " <> inspect(req)}
  end
end
