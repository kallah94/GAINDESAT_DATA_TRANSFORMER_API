defmodule SensorDataProcessing do
  @moduledoc "Documentation for `SensorDataProcessing` Functions define here are for mission data decoding"



  @doc """
    This function take a `%PayloadStruct{}` as input and produce a  `%CollectedDataStruct{}`
  """
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


  @doc """
    This function take a `%CollectedDataStruct{}` as input and produce a  `%DataPacketStruct{}`
  """
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

  @doc """
    This function take a `%CollectedDataStruct{}` as input and produce a `[%DataPacketStruct{}]`
  """
  defp decode_packets(package) do
    package.set_of_data_packet |> Enum.map(fn packet -> decode_sensor_data_packet(package.id_station, packet) end)
  end

  @doc """
    This function take a String chain as input and produce a `%MeasureStruct{}` readable for human when the String chain length is
  equal or greater than 16 and return `nil` otherwise
  """
  defp decode_single_measure(id_station, measure) do
    case byte_size(measure) >= 16 do
      true -> %MeasureStruct{
                id_station: id_station,
                sensor_id: String.slice(measure, 0..1) |> String.to_integer(16),
                parameter_value: String.slice(measure, 2..5) |> String.to_integer(16),
                measure_timestamp: String.slice(measure, 6..13) |> String.to_integer(16) |> DateTime.from_unix!(),
                parameter_type: String.slice(measure, 14..16)
              }
      false -> nil
    end
  end

  @doc """
    This function take a `%DataPacketStruct{}` as input and produce a `[%MeasureStruct{}]`
  """
  defp decode_packet_measures(packet) do
    packet.set_of_measures |> Enum.map(fn measure -> decode_single_measure(packet.id_station, measure) end)
  end


  @doc """
  This function take a list of package and merge packages when they meets conditions define in `concatenable` and return
  a new modified packages list: `packages` => `all_packages`
"""
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

  @doc """
  This function take two packages and test if they are mergeable
"""
  defp concatenable(package_1, package_2) do
    condition = (is_struct(package_1) && (is_struct(package_2)))
    case condition do
      true ->  (package_2.id_station == package_1.id_station)
               && (package_2.nb_total_package == package_1.nb_total_package)
               && (package_1.nb_total_package > package_1.nb_package)
      false -> false
    end
  end

  @doc """
    This function take two package and update set_of_data_packet field of the second package by merging the value with the value of the
    set_of_data_packet of the first package and return the second package
  """
  defp update_package(package1, package2) do
    Map.put(package2, :set_of_data_packet, package1.set_of_data_packet <> package2.set_of_data_packet)
  end

  @doc """
  This function take the field `set_of_data_packet` for a `%CollectedDataStruct{}` and split as a list of string with the
  same length `94`
  """
  defp set_of_packet_splitter(set_of_data_packet) do
    set_of_data_packet
    |> String.split(~r/.{94}/, include_captures: true, trim: true)
  end

  @doc """
  This function take the field `set_of_measures` for a `%DataPacketStruct{}` and split as a list of string with the
  same length `16`
  """
  defp set_measures_splitter(set_of_measures) do
    set_of_measures
    |> String.split(~r/.{16}/, include_captures: true, trim: true)
  end
end
