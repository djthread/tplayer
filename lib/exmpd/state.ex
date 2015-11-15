defmodule ExMpd.State do
  defstruct opts:      %ExMpd.Options{},
            socket:    nil,
            pl:        [],
            version:   nil,

            volume:         nil,
            repeat:         nil,
            random:         nil,
            single:         nil,
            consume:        nil,
            playlist:       nil,
            playlistlength: nil,
            mixrampdb:      nil,
            state:          nil
end
