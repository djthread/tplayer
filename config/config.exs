# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :exmpd, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:exmpd, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

# config :logger, compile_time_purge_level: :info

mpd_host = "localhost"
# mpd_host = "mobius.threadbox.net"
mpd_port = 6600

config :tplayer, mpd_host:  mpd_host,
                 mpd_port:  mpd_port,
                 cache_dir: Path.expand("~/.tplayer/"),
                 # latest_album_count: 1000,
                 # latest_dir: "tmp/stage5"
                 modules:   [
                   {TPlayer.Modules.Core,   []},
                   {TPlayer.Modules.Db,     []},
                   {TPlayer.Modules.Random, []}
                 ]

config :pooler, pools: [
  [
    name:       :mpd,
    group:      :mpd,
    init_count: 2,
    max_count:  5,
    start_mfa:  {ExMpd.Connection, :start_link, [mpd_host, mpd_port]}
  ]
]
