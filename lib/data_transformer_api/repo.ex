defmodule DataTransformerApi.Repo do
  use Ecto.Repo,
    otp_app: :data_transformer_api,
    adapter: Ecto.Adapters.Postgres
end
