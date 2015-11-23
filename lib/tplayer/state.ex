defmodule TPlayer.State do
  defstruct config:    %TPlayer.Config{},
            albums:    []   # in-memory list of all albums!
end
