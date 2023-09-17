# This file is responsible for configuring your application and its
# dependencies.
#
# This configuration file is loaded before any dependency and is restricted to
# this project.
import Config

# Enable the Nerves integration with Mix
Application.start(:nerves_bootstrap)

config :nerves_beacon, target: Mix.target()

config :nerves_beacon, :bluetooth,
  uuid: "92e0244f-9ec5-4472-bde6-f497586be470",
  major: 1,
  minor: 2,
  tx_power: -59,  # This should be an integer (dBm)
  advertising_period: 120_000

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

# Set the SOURCE_DATE_EPOCH date for reproducible builds.
# See https://reproducible-builds.org/docs/source-date-epoch/ for more information

config :nerves, source_date_epoch: "1694868439"

if Mix.target() == :rpi3a do
  config :nerves, :firmware, fwup_conf: "config/fwup.conf"
end


if Mix.target() == :host do
  import_config "host.exs"
else
  import_config "target.exs"
end
