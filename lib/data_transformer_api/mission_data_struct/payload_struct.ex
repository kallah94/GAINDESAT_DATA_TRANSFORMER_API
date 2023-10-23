defmodule PayloadStruct do
  @moduledoc """
  Documentation for `PayloadStruct`
  This Struct represent the payload
"""
  use TypedStruct

  @typedoc "field payload from PlFileStruct structure"
  typedstruct do
    field :cafe, String.t(), default: "cafe", enforce: true
    field :timestamp, DateTime.t(), enforce: false
    field :tc_code, String.t(), enforce: true
    field :data, String.t(), enforce: true
  end
end