defmodule HotPlate.Repo.Migrations.CreateCompaniesAuthTables do
  use Ecto.Migration

  def change do
    create table(:companies) do
      add :email, :string, null: false, size: 160
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime
      timestamps()
    end

    create unique_index(:companies, [:email])

    create table(:companies_tokens) do
      add :company_id, references(:companies, on_delete: :delete_all), null: false
      add :token, :binary, null: false, size: 32
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:companies_tokens, [:company_id])
    create unique_index(:companies_tokens, [:context, :token])
  end
end
