defmodule NervesBeacon.Bluetooth.Transmitter do
  use GenServer

  alias BlueHeron.Peripheral
  alias BlueHeron.DataType.ManufacturerData.Apple
  alias BlueHeron.HCI.Command.ControllerAndBaseband.WriteLocalName

  alias NervesBeacon.Bluetooth.IBeacon

  require Logger

  @init_commands [%WriteLocalName{name: "NervesBeacon iBeacon"}]

  @default_uart_config %{
    # "ttyAMA0" "ttyACM0"
    device: "ttyS0",
    uart_opts: [speed: 115_200],
    init_commands: @init_commands
  }

  # Config for iBeacon advertising parameters
  @advertising_params %{
    # 0.25 sec
    advertising_interval_min: 0x0190,
    # 0.75 sec
    advertising_interval_max: 0x04B0,
    # Advertising type. 0x02 is for scannable undirected advertising.
    advertising_type: 0x02,
    # Own address type. 0x00 is for a public address.
    own_address_type: 0x00,
    # Peer address type. 0x00 is for a public address. Adjust if necessary.
    peer_address_type: 0x00,
    # Address of the peer device. Adjust if you have a specific device to target.
    peer_address: 0x000000000000,
    # Advertising channel map. It's typically 0x07 to use all three channels.
    advertising_channel_map: 0x07,
    # Advertising filter policy. 0x00 allows any device to scan and connect.
    advertising_filter_policy: 0x00
  }

  def start_link(_config) do
    {:ok, config} = Application.fetch_env(:nerves_beacon, :bluetooth)
    Logger.info(inspect(config))

    GenServer.start_link(__MODULE__, config)
  end

  @impl GenServer
  def init(config) do
    # Initialize the GATT Server
    gatt_server = NervesBeacon.Bluetooth.GattServer
    transport_config = struct(BlueHeronTransportUART, @default_uart_config)

    # Initialize transport context
    {:ok, ctx} = BlueHeron.transport(transport_config)
    {:ok, peripheral_pid} = Peripheral.start_link(ctx, gatt_server)

    Logger.info("Setting up iBeacon advertising")

    payload = IBeacon.get_payload(config[:uuid], config[:major], config[:minor], config[:tx_power])
    Logger.info(inspect(payload))

    # Set advertising parameters
    Peripheral.set_advertising_parameters(peripheral_pid, @advertising_params)

    # Set advertising data with the payload
    Peripheral.set_advertising_data(peripheral_pid, payload)

    # Schedule the first advertising event immediately
    Process.send_after(self(), :start_advertising, 100)

    {:ok, %{peripheral_pid: peripheral_pid, gatt_server: gatt_server, config: config}}
  end

  @impl GenServer
  def handle_info(:start_advertising, state) do
    Logger.info("Starting advertising")
    Logger.info("Beacon configuration: " <> inspect(state.config))
    Peripheral.start_advertising(state.peripheral_pid)

    # Advertise for the designated period
    Process.send_after(self(), :stop_advertising, state.config[:advertising_period])

    {:noreply, state}
  end

  def handle_info(:stop_advertising, state) do
    Logger.info("Stopping advertising")
    Peripheral.stop_advertising(state.peripheral_pid)

    # Schedule the next advertising
    Process.send_after(self(), :start_advertising, 1_000)

    {:noreply, state}
  end

end
