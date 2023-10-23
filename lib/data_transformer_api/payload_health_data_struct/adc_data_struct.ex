defmodule AdcDataStruct do
  @moduledoc """
  """
  use TypedStruct

  @typedoc "
`tc_code value should be 01`
"

  typedstruct do
    field :cafe, String.t(length: 4), enforce: true
    field :timestamp, DateTime.t(), enforce: false
    field :tc_code, String.t(), enforce: true
    field :nb_adc, Integer.t(min: 0, max: 10), enforce: true
    field :data, Integer.t(), enforce: true
    field :na, String.t(), enforce: true
  end
end
