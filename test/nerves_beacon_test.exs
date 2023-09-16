defmodule NervesBeaconTest do
  use ExUnit.Case
  doctest NervesBeacon

  test "greets the world" do
    assert NervesBeacon.hello() == :world
  end
end
