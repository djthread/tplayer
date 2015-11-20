defmodule ExMpd.State do
  defstruct config:    %ExMpd.Config{},
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
