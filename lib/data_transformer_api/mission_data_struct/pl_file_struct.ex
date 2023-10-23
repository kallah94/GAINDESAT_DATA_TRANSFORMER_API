defmodule PlFileStruct do
  @moduledoc """
  Documentation for `PlFileStruct`
  This struct represent the payload file format after being decoded by the mcc
  `file_name:` the name of the given payload file
  `payload:` the useful data to decode
"""
  use TypedStruct

  @typedoc "Payload File structure"
  typedstruct do
    field :file_name, String.t(), enforce: false
    field :file_creation_time, DataTime.t(), enforce: false
    field :file_update_time, DataTime.t(), enforce: false
    field :first_sector, Integer.t(), enforce: false
    field :file_size, Integer.t(), enforce: false
    field :root_add, Integer.t(), enforce: false
    field :payload, Integer.t(), enforce: false
  end
end