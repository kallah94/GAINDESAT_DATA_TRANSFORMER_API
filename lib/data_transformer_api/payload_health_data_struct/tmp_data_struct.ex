defmodule TmpDataStruct do
  @moduledoc """
"""
use TypedStruct

@typedoc ""

  typedstruct do
    field :cafe, String.t(length: 4), enforce: true
    field :timestamp, DateTime.t(), enforce: true
    field :tc_code, String.t(length: 2), enforce: true
    field :nb_sensor, Integer.t(), enforce: true
    field :data, Integer.t(), enforce: true
    field :na, String.t(), enforce: true
  end
end
