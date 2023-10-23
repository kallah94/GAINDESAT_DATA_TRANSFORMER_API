defmodule CameraParametersStruct do
  @moduledoc """
"""
  use TypedStruct

  @typedoc ""

  typedstruct do
    field :cafe, String.t(length: 4), enforce: true
    field :timestamp, DateTime.t(), enforce: false
    field :tc_code, String.t(length: 2), enforce: true
    field :brigthness, Integer.t(), enforce: true
    field :contrast, Integer.t(), enforce: true
    field :resolution, Integer.t(), enforce: true
    field :exposition, Integer.t(), enforce: true
    field :na, String.t(), enforce: true
  end
end
