defmodule PictureDataStruct do
  @moduledoc """
  Documentation for `PictureDataeStruct`
"""

  use TypedStruct

  @typedoc "A Picture File model"
  typedstruct do
    field :cafe, String.t(length: 4), enforce: true
    field :timestamp, DateTime.t(), enforce: false
    field :tc_code, String.t(), enforce: true
    field :brigthness, Integer.t(), enforce: true
    field :contrast, Integer.t(), enforce: true
    field :resolution, Integer.t(), enforce: true
    field :exposition, Integer.t(), enforce: true
    field :nb_package, Integer.t(), enforce: true
    field :total_nb_package, Integer.t(), enforce: true
    field :size_package, Integer.t(), enforce: true
    field :data, String.t(), enforce: true
  end
end
