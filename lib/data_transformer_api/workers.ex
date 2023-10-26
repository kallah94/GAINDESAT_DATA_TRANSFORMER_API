
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


  def decode_measures(files) do
    files
    |> concat_payload_files_data
    |> List.delete_at(0)
    |> Enum.map(fn file -> decode_payload_file(file) end)
    |> Enum.map(fn payload -> decoder(payload) end)
    |> Enum.filter(fn decoded_payload -> is_struct(decoded_payload) end)
    |> packet_assembler([])
    |> Enum.map(fn package ->  Map.put(package, :set_of_data_packet, package.set_of_data_packet |> set_of_packet_splitter) end)
    |> Enum.map(fn package -> decode_packets(package) end)
    |> List.flatten
    |> Enum.map(fn packet -> Map.put(packet, :set_of_measures, packet.set_of_measures |> set_measures_splitter) end)
    |> Enum.map(fn packet -> decode_packet_measures(packet) end)
    |> List.flatten

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

  def concat_payload_files_data(files) do
    files
    |> Enum.map(fn file -> file.decoded_str end)
    |> process_data()
    |> Enum.map( fn file -> file.payload end)
    |> List.foldr("", fn payload, acc -> payload <> acc end)
    |> String.split("cafe")
  end


  def decode_sensor_data_packet(id_station, packet) do
    %DataPacketStruct{
        id_station: id_station,
        na: String.slice(packet, 0..1),
        number_total_of_packet: String.slice(packet, 4..5) <> String.slice(packet, 2..3) |> String.to_integer(16),
        number_of_packet: String.slice(packet, 8..9) <> String.slice(packet, 6..7) |> String.to_integer(16),
        number_total_of_measures: String.slice(packet, 10..13) |> String.to_integer(16),
        set_of_measures: String.slice(packet, 14..-1//1)
    }
  end

  def decode_packets(package) do
    package.set_of_data_packet |> Enum.map(fn packet -> decode_sensor_data_packet(package.id_station, packet) end)
  end

  def decode_single_measure(id_station, measure)  when byte_size(measure) >= 16 do
      %MeasureStruct{
        id_station: id_station,
        sensor_id: String.slice(measure, 0..1) |> String.to_integer(16),
        parameter_value: String.slice(measure, 2..5) |> String.to_integer(16),
        measure_timestamp: String.slice(measure, 6..13) |> String.to_integer(16) |> DateTime.from_unix!(),
        parameter_type: String.slice(measure, 14..16)
      }
  end

  def decode_single_measure(_id_station, measure) when byte_size(measure) < 16 do
    nil
  end

  def decode_packet_measures(packet) do
    packet.set_of_measures |> Enum.map(fn measure -> decode_single_measure(packet.id_station, measure) end)
  end


  def packet_assembler(packages, all_packages) do
    cond do
      length(packages) == 0 -> all_packages
      length(packages) > 0 ->
        package1 = packages |> List.first
        packages = packages |> List.delete_at(0)
        package2 = packages |> List.first
        case concatenable(package1, package2) do
          true ->
                all_packages = List.insert_at(all_packages, -1, update_package(package1, package2))
                packages = packages |> List.delete_at(0)
                packet_assembler(packages, all_packages)
          false ->
                  all_packages =  List.insert_at(all_packages, -1, package1)
                  packet_assembler(packages, all_packages)
        end
    end
  end

  def concatenable(package_1, package_2) do
    condition = (is_struct(package_1) && (is_struct(package_2)))
    case condition do
       true ->  (package_2.id_station == package_1.id_station)
                && (package_2.nb_total_package == package_1.nb_total_package)
                && (package_1.nb_total_package > package_1.nb_package)
       false -> false
    end

  end

  def update_package(package1, package2) do
    Map.put(package2, :set_of_data_packet, package1.set_of_data_packet <> package2.set_of_data_packet)
  end

  def set_of_packet_splitter(set_of_data_packet) do
    set_of_data_packet
    |> String.split(~r/.{94}/, include_captures: true, trim: true)
  end

  def set_measures_splitter(set_of_measures) do
    set_of_measures
    |> String.split(~r/.{16}/, include_captures: true, trim: true)
  end

  def decoder(payload) do
    case payload.tc_code do
      "0a" -> decode_sensor_data_package(payload)
      _ -> {:ok, "not implemented"}
    end
  end

end
