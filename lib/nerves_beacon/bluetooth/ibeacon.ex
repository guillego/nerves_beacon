defmodule NervesBeacon.Bluetooth.IBeacon do

  alias BlueHeron.DataType.ManufacturerData.Apple

  @preamble %{
    flag_length: 0x02,
    flag_type: 0x01,
    flag_value: 0x06,
    manufacturer_data_length: 0x1A,
    manufacturer_data_type: 0xFF,
    manufacturer_data_company_id: [0x4C, 0x00]
  }

  def get_payload(uuid, major, minor, tx_power) do
    uuid_integer =
      uuid
      |> UUID.string_to_binary!()
      |> :binary.decode_unsigned()

    {:ok, beacon_data} =
      Apple.serialize(
        {"iBeacon",
         %{
           major: major,
           minor: minor,
           tx_power: tx_power,
           uuid: uuid_integer
         }}
      )

    get_preamble() <> beacon_data
  end

  defp get_preamble do
    <<
      @preamble.flag_length,
      @preamble.flag_type,
      @preamble.flag_value,
      @preamble.manufacturer_data_length,
      @preamble.manufacturer_data_type,
      Enum.at(@preamble.manufacturer_data_company_id,0),
      Enum.at(@preamble.manufacturer_data_company_id,1)
    >>
  end
end
