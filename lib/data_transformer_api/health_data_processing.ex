defmodule DataTransformerApi.HealthDataProcessing do
  @moduledoc " Module to decode and show health data"

  defp decode_gyro_data(payload) do
    data = payload.data
    %GyroInformationStruct{
      cafe: payload.cafe,
      timestamp: payload.timestamp,
      tc_code: payload.tc_code,
      gyro_data_x: String.slice(data, 0..3),
      gyro_data_y: String.slice(data, 4..7),
      gyro_data_z: String.slice(data, 8..11),
      accel_data_x: String.slice(data, 12..15),
      accel_data_y: String.slice(data, 16..19),
      accel_data_z: String.slice(data, 20..23),
      temp_data: String.slice(data, 24..27),
      na: String.slice(data, 28..-1//1)
    }
  end

  def decoder(payload) do
    case payload.tc_code do
      "07" -> decode_gyro_data(payload)
      _ -> {:ok, "not concern"}
    end
  end
end
