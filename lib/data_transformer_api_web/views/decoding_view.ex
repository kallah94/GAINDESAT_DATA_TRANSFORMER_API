defmodule DataTransformerApiWeb.DecodingView do
  use DataTransformerApiWeb, :view
  alias DataTransformerApiWeb.DecodingView
  alias DataTransformerApi.Decoding

  def render("decode.json", %{decoding: decoding}) do
    %{
    token: "",
    startDate: decoding.startDate,
    endDate: decoding.endDate
    }
  end
end