defmodule DataTransformerApi.Repo.Migrations.CreateGaindesat1File do
  use Ecto.Migration

  def change do
    create table(:gaindesat1_file, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :id, :integer
      add :timestamp, :utc_datetime
      add :raw, :string
      add :decoded_str, :string
      add :file_name, :string
      add :file_creation_timestamp, :utc_datetime
      add :file_modification_timestamp, :utc_datetime
      add :first_sector, :string
      add :file_size, :string
      add :root_address, :string

      timestamps()
    end

  end
end
