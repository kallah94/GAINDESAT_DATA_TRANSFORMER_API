defmodule MeasureStruct do
  @moduledoc """
  Documentation for `MeasureStruct`
  This Struct represent the sensor data file format
"""

  @parameters_values %{
  "01": "water_height",
  "02": "water_temp",
  "03": "ambient_temp",
  "04": "precipitations",
  "05": "wind_speed",
  "06": "wind_direction",
  "07": "specific_water_conductivity",
  "08": "salinity",
  "09": "total_dissolved_solids",
  "0a": "compass",
  "0b": "relative_water_humidity",
  "0c": "barometric_pressure",
  "0d": "global_radiation"
  }
  use TypedStruct

  @typedoc "A sensor data format"
  typedstruct do
    field :sensor_id, Integer.t(), enforce: true
    field :parameter_value, Integer.t(), enforce: true
    field :measure_timestamp, DateTime.t(), enforce: false
    field :parameter_type, String.t(), enforce: false
  end

end
