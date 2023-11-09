defmodule DataTransformerApi.SensorDataProcessing do
  @moduledoc "Documentation for `SensorDataProcessing` Functions define here are for mission data decoding"
  import DataTransformerApi.Workers, only: [decode_payload_file: 1, concat_payload_files_data: 1]
  alias Elixlsx.{Sheet, Workbook}

  defp decode_sensor_data_package(payload) do
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

  defp decode_sensor_data_packet(id_station, packet) do
    %DataPacketStruct{
      id_station: id_station,
      na: String.slice(packet, 0..1),
      number_total_of_packet: String.slice(packet, 4..5) <> String.slice(packet, 2..3) |> String.to_integer(16),
      number_of_packet: String.slice(packet, 8..9) <> String.slice(packet, 6..7) |> String.to_integer(16),
      number_total_of_measures: String.slice(packet, 10..13) |> String.to_integer(16),
      set_of_measures: String.slice(packet, 14..-1//1)
    }
  end

  defp decode_packets(package) do
    package.set_of_data_packet |> Enum.map(fn packet -> decode_sensor_data_packet(package.id_station, packet) end)
  end

  defp parameter_type_setter(parameter_code) do
    case parameter_code do
      "01" -> "water_height"
      "02" -> "water_temp"
      "03" -> "ambient_temp"
      "04" -> "precipitations"
      "05" -> "wind_speed"
      "06" -> "wind_direction"
      "07" -> "specific_water_conductivity"
      "08" -> "salinity"
      "09" -> "total_dissolved_solids"
      "0a" -> "compass"
      "0b" -> "relative_water_humidity"
      "0c" -> "barometric_pressure"
      "0d" -> "global_radiation"
      _ -> "Unknown"
    end
  end

  defp decode_single_measure(id_station, measure) do
    case byte_size(measure) >= 16 do
      true -> %MeasureStruct{
                id_station: id_station,
                sensor_id: String.slice(measure, 0..1) |> String.to_integer(16),
                parameter_value: String.slice(measure, 2..5) |> String.to_integer(16),
                measure_timestamp: String.slice(measure, 6..13) |> String.to_integer(16) |> DateTime.from_unix!(),
                parameter_type: String.slice(measure, 14..16) |> parameter_type_setter
              }
      false -> nil
    end
  end

  defp decode_packet_measures(packet) do
    packet.set_of_measures |> Enum.map(fn measure -> decode_single_measure(packet.id_station, measure) end)
  end

  defp packet_assembler(packages, all_packages) do
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

  defp concatenable(package_1, package_2) do
    condition = (is_struct(package_1) && (is_struct(package_2)))
    case condition do
      true ->  (package_2.id_station == package_1.id_station)
               && (package_2.nb_total_package == package_1.nb_total_package)
               && (package_1.nb_total_package > package_1.nb_package)
      false -> false
    end
  end

  defp update_package(package1, package2) do
    Map.put(package2, :set_of_data_packet, package1.set_of_data_packet <> package2.set_of_data_packet)
  end


  defp set_of_packet_splitter(set_of_data_packet) do
    set_of_data_packet
    |> String.split(~r/.{94}/, include_captures: true, trim: true)
  end

  defp set_measures_splitter(set_of_measures) do
    set_of_measures
    |> String.split(~r/.{16}/, include_captures: true, trim: true)
  end

  defp decoder(payload) do
    case payload.tc_code do
      "0a" -> decode_sensor_data_package(payload)
      _ -> {:ok, "not concern"}
    end
  end

  defp measure_transformer(measure) do
    [measure.id_station, measure.sensor_id, measure.parameter_value, measure.parameter_type, DateTime.to_string(measure.measure_timestamp)]
  end

  defp measures_collector(measures) do
    measures |> Enum.map(fn measure -> measure_transformer(measure) end)
  end

  defp excel_writer(measures) do
    sheet = Sheet.with_name("STATION-DATA.xlsx")
    workbook = %Workbook{}
    cell_titles = ["station_id", "sensor_id", "value", "parameter_type", "timestamp"]
    measures = measures_collector(measures) |> List.insert_at(0, cell_titles)
    sheet = Map.put(sheet, :rows, measures)
    workbook = Workbook.append_sheet(workbook, sheet)
    workbook |> Elixlsx.write_to("CollectedData.xlsx")
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
    |> Enum.filter(fn data -> data != nil end)
    |> excel_writer()
  end
end
