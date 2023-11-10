
defmodule DataTransformerApi.Workers do
  @moduledoc "Functions use to transform data"

  def process_data([]) do
    []
  end

  def process_data([first | rest]) do
    [process_element(first) | process_data(rest)]
  end

  def process_element(element) do
    data = element
           |> String.split(",")
    data = Enum.zip([:file_name, :file_creation_time, :file_modification_time, :first_sector, :file_size, :root_add, :payload], data)
           |> Enum.into(%{})
    %PlFileStruct{
      file_name: data.file_name,
      file_creation_time: data.file_creation_time,
      file_update_time: data.file_modification_time,
      first_sector: data.first_sector,
      file_size: data.file_size,
      root_add: data.root_add,
      payload: data.payload |> String.replace(" ", "") #|> String.split(~r/.{4}/, include_captures: true, trim: true)
    }
  end

  def decode_timestamp(timestamp) do
    timestamp
    |> String.to_integer(16)
    |> DateTime.from_unix!
  end

  def decode_payload_file(data) do
    cond do
      byte_size(data) > 0 ->
        %PayloadStruct{
          cafe: "cafe",
          timestamp: String.slice(data, 0..7) |> decode_timestamp,
          tc_code: String.slice(data, 8..9),
          data: String.slice(data, 10..-1//1)
        }
      byte_size(data) == 0 -> {:error, "empty string"}
    end
  end

  def concat_payload_files_data(files) do
    files
    |> Enum.map(fn file -> file.decoded_str end)
    |> process_data()
    |> Enum.map( fn file -> file.payload end)
    |> List.foldr("", fn payload, acc -> payload <> acc end)
    |> String.split("cafe")
    |> List.delete_at(0)
  end

end
