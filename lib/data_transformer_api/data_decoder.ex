defmodule DataDecoder do
  @moduledoc "Module for decoding data from MCC Database"


  @doc "this function si for reading data mission from MCC"
  def file_reader(path) do
    File.stream!(path)
    |> Enum.map(&String.trim/1)
  end


end
