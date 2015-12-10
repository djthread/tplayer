# TPlayer

Elixir app for controlling an MPD instance. ExMpd represents a sort of MPD-interaction library layer that could one day be pulled into a separate pacakage.

This project is very, very much a work in progress. Not much functionality is available just yet, and a main purpose is to learn me some Elixir... hopefully for great good.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add exmpd to your list of dependencies in `mix.exs`:

        def deps do
          [{:exmpd, "~> 0.0.1"}]
        end

  2. Ensure exmpd is started before your application:

        def application do
          [applications: [:exmpd]]
        end
