defmodule DataTransformerApi.Service do
  @moduledoc "DataTransformer module to fetch data from MCC database
    and handle the creation of DDP entities"


  import Ecto.Query
  alias DataTransformerApi.Repo
  alias DataTransformerApi.Gaindesat1File
  alias PlFileStruct
  alias HTTPoison
  alias TokenStruct
  alias DataTransformerApi.SensorDataProcessing
  @admin_username "Admin"
  @admin_password "moussaFall"
  @auth_url "http://localhost:8080/api/auth/signin"
  @mission_data_url "localhost:8080/api/v1/admin/mission-data/dt"
  @default_date DateTime.utc_now() |> DateTime.add(-24, :hour)
  @default_next_date DateTime.utc_now() |> DateTime.add(24, :hour)
  @pl_file_prefix "PL%"


  def decode_measures(files), do: SensorDataProcessing.decode_measures(files)


  def get_token() do
   body = Poison.encode!(%{
     username: @admin_username,
     password: @admin_password,
   })

   case HTTPoison.post( @auth_url, body, %{"Content-Type" => "application/json"}) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body }} -> Poison.decode!(body, as: %TokenStruct{})

      {:ok, %HTTPoison.Response{status_code: 401, body: body }} -> Poison.decode!(body)

      {:error, %HTTPoison.Error{reason: :econnrefused, id: nil}} -> {:error, "Server not response"}

      _ -> {:error, "Any clause match"}
   end
  end

  def create_mission_data(measure) do
    body = Poison.encode!(measure)

    case HTTPoison.post(@mission_data_url, body, %{"Content-Type" => "application/json", "Authorization" => "Bearer #{get_token().accessToken}"}) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body }} -> Poison.decode!(body)
      {:error, %HTTPoison.Error{reason: :econnrefused, id: nil}} -> {:error, "Server not response"}
      {:ok, %HTTPoison.Response{status_code: 500, body: "not saved"}} -> {:error, "Measure not saved"}
      {_, _} -> {:error, "Error Occur"}
    end
  end

  def fetch_payload_files do
    from(
          file in Gaindesat1File,
          where: like(file.file_name, ^@pl_file_prefix),
          select: file
    )
    |> Repo.all
  end

  def fetch_recent_payload_files(date\\ @default_date) do
    case Timex.is_valid?(date) do
      true ->
        from(
        file in Gaindesat1File,
        where: like(file.file_name, ^@pl_file_prefix ) and (file.file_modification_timestamp >= ^date),
        order_by: [asc: :file_modification_timestamp, asc: :file_name],
        select: file
        )
        |> Repo.all
      false -> {:error, "Date not valid, provide UTC date format"}
    end
  end

  def fetch_payload_today_files(begin_date, end_date) do
    case (Timex.is_valid?(begin_date) and Timex.is_valid?(end_date)) do
      true ->
        from(
          file in Gaindesat1File,
            where: like(file.file_name, ^@pl_file_prefix) and (file.file_modification_timestamp >= ^begin_date and file.file_modification_timestamp <= ^end_date),
            order_by: [asc: :file_modification_timestamp, asc: :file_name],
            select: file
        )
        |> Repo.all
      false -> {:error, "Date not valid, provide UTC date format"}
    end
  end
end
