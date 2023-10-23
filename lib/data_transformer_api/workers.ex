
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
    %PayloadStruct{
      cafe: "cafe",
      timestamp: String.slice(data, 0..7) |> decode_timestamp,
      tc_code: String.slice(data, 8..9),
      data: String.slice(data, 10..-1//1)
    }
  end

  def decode_sensor_data_package(payload) do
    %CollectedDataStruct{
      cafe: payload.cafe,
      timestamp: payload.timestamp,
      tc_code: payload.tc_code,
      id_station: String.slice(payload.data, 0..1) |> String.to_integer(16),
      nb_package: String.slice(payload.data, 2..3) |> String.to_integer(16),
      nb_total_package: String.slice(payload.data, 4..5) |> String.to_integer(16),
      size_package: String.slice(payload.data, 6..9) |> String.to_integer(16),
      set_of_data_packet: String.slice(payload.data, 10..-1//1)
    }
  end

  def decode_sensor_data_packet(data) do
      %DataPacketStruct{
        na: String.slice(data, 0..1),
        number_total_of_measures: String.slice(data, 4..5) <> String.slice(data, 2..3) |> String.to_integer(16),
        number_of_packet: String.slice(data, 8..9) <> String.slice(data, 6..7) |> String.to_integer(16),
        number_total_of_packet: String.slice(data, 10..13) |> String.to_integer(16),
        set_of_measures: String.slice(data, 14..-1//1)
      }
  end

  def set_of_packet_splitter(set_of_data_packet) do
    set_of_data_packet
    |> String.split(~r/.{94}/, include_captures: true, trim: true)
  end

  def set_measures_splitter(set_of_measures) do
    set_of_measures
    |> String.split(~r/.{16}/, include_captures: true, trim: true)
  end

  def decode_measure(measure) do
    case byte_size(measure) do
      16 ->
      %MeasureStruct{
        sensor_id: String.slice(measure, 0..1) |> String.to_integer(16),
        parameter_value: String.slice(measure, 2..5) |> String.to_integer(16),
        measure_timestamp: String.slice(measure, 6..13) |> String.to_integer(16) |> DateTime.from_unix!(),
        parameter_type: String.slice(measure, 14..16)
      }

      _ -> measure
    end

  end


  def decoder(payload) do
    case payload.tc_code do
      "0a" -> decode_sensor_data_package(payload)
      _ -> {:ok, "not implemented"}
    end
  end

end
