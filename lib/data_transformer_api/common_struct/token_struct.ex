defmodule TokenStruct do
  @moduledoc "Struct use to get accessToken and type from admin connection"


  use TypedStruct

  @typedoc "accessToken information"

  typedstruct do
    field :tokenType, String.t()
    field :accessToken, String.t()
  end
end
