defmodule DataPacketStruct do
  @moduledoc """
  Documentation for `DataPacketStruct`
This structure represent the data model for packet
"""
  use TypedStruct

  @typedoc "A packet of sensor data"
  typedstruct do
    field :id_station, Integer.t(), enforce: true
    field :na, String.t(), enforce: true
    field :number_total_of_measures, Integer.t(), enforce: true
    field :number_of_packet, Integer.t(), enforce: true
    field :number_total_of_packet, Integer.t(), enforce: true
    field :set_of_measures, String.t(), enforce: true
  end
end
