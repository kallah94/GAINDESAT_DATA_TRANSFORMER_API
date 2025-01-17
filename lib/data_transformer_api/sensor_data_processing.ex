defmodule DataTransformerApi.SensorDataProcessing do
  @moduledoc "Documentation for `SensorDataProcessing` Functions define here are for mission data decoding"
  import DataTransformerApi.Workers, only: [decode_payload_file: 1, concat_payload_files_data: 1]
  import DataTransformerApi.Service, only: [create_mission_data: 2]
  alias Elixlsx.{Sheet, Workbook}

  def decode_sensor_data_package(payload) do
    %CollectedDataStruct{
      cafe: payload.cafe,
      timestamp: payload.timestamp,
      tc_code: payload.tc_code,
      id_station: String.slice(payload.data, 0..1),
      nb_package: String.slice(payload.data, 2..3) |> String.to_integer(16),
      nb_total_package: String.slice(payload.data, 4..5) |> String.to_integer(16),
      size_package: String.slice(payload.data, 6..9) |> String.to_integer(16),
      set_of_data_packet: String.slice(payload.data, 10..-1//1)
    }
  end

  def decode_sensor_data_packet(id_station, packet) do
    case byte_size(packet) >= 16 do
      true ->
        %DataPacketStruct{
        id_station: id_station,
        na: String.slice(packet, 0..1),
        number_of_packet: String.slice(packet, 4..5) <> String.slice(packet, 2..3) |> String.to_integer(16),
        number_total_of_packet: String.slice(packet, 8..9) <> String.slice(packet, 6..7) |> String.to_integer(16),
        number_total_of_measures: String.slice(packet, 10..13) |> String.to_integer(16),
        set_of_measures: String.slice(packet, 14..-1//1)
      }
      false -> nil
    end
  end

  def decode_packets(package) do
    package.set_of_data_packet
    |> Enum.map(fn packet -> decode_sensor_data_packet(package.id_station, packet) end)
    |> Enum.filter(fn packet -> packet != nil end)
    end

  def parameter_type_setter(parameter_code) do
    case parameter_code do
      "01" -> "Hauteur Eau"
      "02" -> "Température Eau"
      "03" -> "Température Ambiante"
      "04" -> "Precipitations"
      "05" -> "Vitesse Vent"
      "06" -> "Orientation Vent"
      "07" -> "Conductivité Specifique Eau"
      "08" -> "Salinité"
      "09" -> "TDS"
      "0a" -> "Boussole"
      "0b" -> "Humudité Relative Eau"
      "0c" -> "Pression Barométrique"
      "0d" -> "Rayonnement Global"
      "00" -> "Defaut"
      _ -> "Unknown"
    end
  end

  def parameter_unit_setter(parameter_code) do
    case parameter_code do
      "01" -> "m"
      "02" -> "°C"
      "03" -> "°C"
      "04" -> "mm"
      "05" -> "km/h"
      "06" -> "°"
      "07" -> "tbd"
      "08" -> "tbd"
      "09" -> "tbd"
      "0a" -> "tbd"
      "0b" -> "tbd"
      "0c" -> "tbd"
      "0d" -> "tbd"
      _ -> "unknown"
    end
  end

  def station_code_setter(station_id) do
    case station_id do
      "06" -> "STE"
      "07" -> "BNG"
      "08" -> "ZOR"
      "09" -> "NTH"
      "0a" -> "NBA"
      "0b" -> "DYE"
      "0c" -> "RLL"
      "0d" -> "NGL"
      _ -> "unknown"
    end
  end

  def sensor_code_setter(sensor_id, station_id) do
    case sensor_id do
      "01" -> "PLS-C_"<>station_id
      "02" -> "SE200_"<>station_id
      "03" -> "WS601_"<>station_id
      "04" -> "PLS-C_"<>station_id
      "05" -> "SE200_"<>station_id
      "06" -> "WS601_"<>station_id
      "07" -> "PLS-C_"<>station_id
      "08" -> "SE200_"<>station_id
      "09" -> "WS601_"<>station_id
      "0a" -> "PLS-C_"<>station_id
      "0b" -> "SE200_"<>station_id
      "0c" -> "WS601_"<>station_id
      "0d" -> "PLS-C_"<>station_id
      "0e" -> "SE200_"<>station_id
      "0F" -> "WS601_"<>station_id
      "00" -> "Default_"<>station_id
      _ -> "Unknown"
    end
  end

  def decode_single_measure(id_station, measure) do
    id_station = id_station |> station_code_setter
    case byte_size(measure) >= 16 do
      true -> %MeasureStruct{
                id_station: id_station,
                sensor_id: String.slice(measure, 0..1) |> sensor_code_setter(id_station),
                parameter_value: String.slice(measure, 2..5) |> String.to_integer(16),
                measure_timestamp: String.slice(measure, 6..13) |> String.to_integer(16) |> DateTime.from_unix!() |> DateTime.to_naive(),
                parameter_type: String.slice(measure, 14..16) |> parameter_type_setter,
                unit: String.slice(measure, 14..16) |> parameter_unit_setter
              }
      false -> nil
    end
  end

  def decode_packet_measures(packet) do
    packet.set_of_measures |> Enum.map(fn measure -> decode_single_measure(packet.id_station, measure) end)
  end

  def packet_assembler(packages, all_packages) when length(packages) <= 0 do
    all_packages
  end

  def packet_assembler(packages, all_packages) do
    package1 = packages |> List.first
    packages = packages |> List.delete_at(0)
    package2 = packages |> List.first
    case concatenable(package1, package2) do
      true ->
        packages = packages |> List.delete_at(0)
        temp_package = update_package(package1, package2)
        case (temp_package.nb_package < temp_package.nb_total_package) do
          true ->
            packages = packages |> List.insert_at(0, temp_package)
            packet_assembler(packages, all_packages)
          false ->
            packages = packages
            all_packages = all_packages |> List.insert_at(-1, temp_package)
            packet_assembler(packages, all_packages)
        end

      false ->
        all_packages =  List.insert_at(all_packages, -1, package1)
        packet_assembler(packages, all_packages)
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

  def measure_transformer(measure) do
    [measure.id_station, measure.sensor_id, measure.parameter_value, measure.parameter_type, DateTime.to_string(measure.measure_timestamp)]
  end

  def measures_collector(measures) do
    measures |> Enum.map(fn measure -> measure_transformer(measure) end)
  end

  def excel_writer(measures) do
    sheet = Sheet.with_name("STATION-DATA.xlsx")
    workbook = %Workbook{}
    cell_titles = ["station_code", "sensor_code", "value", "parameter_type", "timestamp"]
    measures = measures_collector(measures) |> List.insert_at(0, cell_titles)
    sheet = Map.put(sheet, :rows, measures)
    workbook = Workbook.append_sheet(workbook, sheet)
    workbook |> Elixlsx.write_to("CollectedData.xlsx")
  end

  def decode_measures(files, token) do
    files
    |> concat_payload_files_data
    |> Enum.map(fn file -> decode_payload_file(file) end)
    |> Enum.filter(fn data -> data.tc_code == "0a" end )
    |> Enum.map(fn payload -> decode_sensor_data_package(payload) end)
    |> Enum.filter(fn decoded_payload -> is_struct(decoded_payload) end)
    |> packet_assembler([])
    |> Enum.map(fn package ->  Map.put(package, :set_of_data_packet, package.set_of_data_packet |> set_of_packet_splitter) end)
    |> Enum.map(fn package -> decode_packets(package) end)
    |> List.flatten
    |> Enum.filter( fn packet -> packet.number_total_of_measures <= 420 end)
    |> Enum.map(fn packet -> Map.put(packet, :set_of_measures, packet.set_of_measures |> set_measures_splitter) end)
    |> Enum.map(fn packet -> decode_packet_measures(packet) end)
    |> List.flatten
    |> Enum.filter(fn data -> data != nil end)
    |> Enum.map(fn measure -> create_mission_data(measure, token) end)
  end
end
