# NervesBeacon
Sample implementation of an iBeacon device in Nerves for RPI3A+ using BlueHeron

The code is ready to work as is.

Beacon parameters can be changed through `config/config.exs`

If you also need wifi connectivity to your device (to ssh into it for example), make sure you configure VintageNet in `config/target.exs`.

## Targets

Only `rpi3a` supported right now, though the implementation code should be valid for other targets.

https://hexdocs.pm/nerves/targets.html#content

## Getting Started

To start your Nerves app:
  * `export MIX_TARGET=rpi3a`
  * Install dependencies with `mix deps.get`
  * Create firmware with `mix firmware`
  * Burn to an SD card with `mix burn`