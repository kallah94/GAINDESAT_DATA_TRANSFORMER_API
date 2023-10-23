defmodule StationDataStruct do
  @moduledoc """
  Documentation for `StationDataStruct`
  """
  use TypedStruct

  @typedoc "Station status data format
    `tc_code value should be 11`
    `if station_status = 0 => Station inactive`
    `if station_status = 1 => Station active`
"

  typedstruct do
    field :cafe, String.t(length: 4), enforce: true # cafe value should be "cafe"
    field :timestamp, DateTime.t(), enforce: true
    field :tc_code, String.t(length: 2), enforce: true # tc_code value should be 11
    field :station_status, Integer.t(min: 0, max: 1), enforce: true # 0 => Inactive 1 => Active
    field :na, String.t(), enforce: true
  end
end
