defmodule GyroInformationStruct do
  @moduledoc """
"""

  use TypedStruct

  @typedoc""

  typedstruct do
    field :cafe, String.t(length: 4), enforce: true
    field :timestamp, DateTime.t(), enforce: false
    field :tc_code, String.t(length: 2), enforce: true
    field :gyro_data_x, Integer.t(), enforce: true
    field :gyro_data_y, Integer.t(), enforce: true
    field :gyro_data_z, Integer.t(), enforce: true
    field :accel_data_x, Integer.t(), enforce: true
    field :accel_data_y, Integer.t(), enforce: true
    field :accel_data_z, Integer.t(), enforce: true
    field :temp_data, Integer.t(), enforce: true
    field :na, String.t(), enforce: true

    
  end
end
