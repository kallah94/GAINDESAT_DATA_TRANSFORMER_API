defmodule DataTransformerApiWeb.DecodingController do
  use DataTransformerApiWeb, :controller

  alias DataTransformerApi.Decoding
  import DataTransformerApi.SensorDataProcessing, only: [decode_measures: 2]
  import DataTransformerApi.Service, only: [fetch_payload_today_files: 2]
  action_fallback DataTransformerApiWeb.FallbackController

  def decode(conn, decoding) do
    IO.inspect(decoding)
    decoding_with_atom_keys = for {key, val} <- decoding, into: %{} do
      {String.to_existing_atom(key), val}
    end
    decoding_struct = struct(Decoding, decoding_with_atom_keys)
    final_startDate =
    decoding_struct.startDate
    |> Timex.parse!("{YYYY}-{0M}-{0D} {h24}:{m}:{s}{ss}")
    |> Timex.to_datetime("UTC")
    final_endDate =
    decoding_struct.endDate
    |> Timex.parse!("{YYYY}-{0M}-{0D} {h24}:{m}:{s}{ss}")
    |> Timex.to_datetime("UTC")
    decoding_struct = Map.put(decoding_struct, :startDate, final_startDate)
    decoding_struct = Map.put(decoding_struct, :endDate, final_endDate)
    fetch_payload_today_files(decoding_struct.startDate, decoding_struct.endDate) |> decode_measures(decoding_struct.token)
    render(conn, "decode.json", decoding: decoding_struct)
  end
end