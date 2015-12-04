defmodule TPlayer.Util do
  require Logger
  alias   TPlayer.State

  def fix_path(path = "/" <> _, _base), do: path
  def fix_path(path, base),             do: Path.expand(path, base)

  def dispatch(type, input, modules, st = %State{}) do
    to_f_atom = fn(name) -> Atom.to_string(type) <> "_#{name}" |> String.to_atom end
    cond do
      is_atom(input) ->
        [input |> to_f_atom.()]
      is_tuple(input) ->
        list = Tuple.to_list(input)
        [hd(list) |> to_f_atom.() | tl(list)]
    end
    |> dispatch modules, st
  end
  def dispatch([f_atom | params], [mod | tail], st = %State{}) when is_atom(f_atom) do
    if {f_atom, length(params) + 1} in mod.__info__(:functions) do
      Logger.debug "Invoking #{Atom.to_string mod}.#{Atom.to_string f_atom}..."
      apply mod, f_atom, params ++ [st]
    else
      dispatch [f_atom | params], tail, st
    end
  end
  def dispatch([f_atom | params], [], _) do
    {:error, "No method found: " <> Atom.to_string(f_atom) <> " (#{inspect params})"}
  end

end
