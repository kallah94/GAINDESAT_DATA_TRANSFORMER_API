defmodule DataTransformerApi.Gaindesat1File do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :integer, autogenerate: false}
  @foreign_key_type :binary_id
  schema "gaindesat1_file" do
    #field :raw, :string
    field :timestamp, :utc_datetime
    field :file_name, :string
    field :decoded_str, :string
    field :file_creation_timestamp, :utc_datetime
    field :file_modification_timestamp, :utc_datetime
    field :first_sector, :string
    field :file_size, :string
    field :root_address, :string

    #timestamps()
  end

  @doc false
  def changeset(gaindesat1_file, attrs) do
    gaindesat1_file
    |> cast(attrs, [:id, :timestamp, :raw, :decoded_str, :file_name, :file_creation_timestamp, :file_modification_timestamp, :first_sector, :file_size, :root_address])
    |> validate_required([:id, :timestamp, :raw, :decoded_str, :file_name, :file_creation_timestamp, :file_modification_timestamp, :first_sector, :file_size, :root_address])
  end
end
