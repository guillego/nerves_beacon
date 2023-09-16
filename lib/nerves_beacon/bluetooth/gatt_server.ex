defmodule NervesBeacon.Bluetooth.GattServer do
  @behaviour BlueHeron.GATT.Server
  require Logger

  @server_name "NervesBeacon GATT"

  @impl BlueHeron.GATT.Server
  def profile() do
    [
      BlueHeron.GATT.Service.new(%{
        id: :gap,
        type: 0x1800,
        characteristics: [
          BlueHeron.GATT.Characteristic.new(%{
            id: {:gap, :device_name},
            type: 0x2A00,  # Standard UUID for "Device Name" characteristic.
            properties: 0b0000010  # Read-only property.
          })
        ]
      })
    ]
  end

  @impl BlueHeron.GATT.Server
  def read({:gap, :device_name}), do: @server_name

  @impl BlueHeron.GATT.Server
  def write(_tuple, value) do
    Logger.info("Received a write attempt to write: #{value}")
  end
end
