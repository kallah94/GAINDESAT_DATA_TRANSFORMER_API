defmodule DataTransformerApi.Decoding do
  @moduledoc ""

  use TypedStruct

  @typedoc ""

  @derive Jason.Encoder
  typedstruct do
    field :startDate, Datetimes.t(), enforce: false
    field :endDate, Datetimes.t(), enforce: false
    field :token, String.t(), enforce: true
  end
end
