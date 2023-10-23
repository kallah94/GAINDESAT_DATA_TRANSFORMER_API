defmodule CollectedDataStruct do
  @moduledoc """
  Documentation for `CollectedDataStruct`
"""
  use TypedStruct

  @typedoc "Collected data structure: this structure represent data model for the field in the `PayloadStruct` when
`tc_code value = 0xa`"
  typedstruct do
    field :cafe, String.t(), enforce: "cafe"
    field :timestamp, Datetimes.t(), enforce: false
    field :tc_code, String.t(), enforce: "0xa"
    field :id_station, Integer.t(min: 0, max: 14), enforce: true
    field :nb_package, Integer.t(), enforce: true
    field :nb_total_package, Integer.t(), enforce: true
    field :size_package, Integer.t(), enforce: true
    field :set_of_data_packet, String.t(), enforce: true
  end
end
