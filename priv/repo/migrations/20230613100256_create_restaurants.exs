defmodule HotPlate.Repo.Migrations.CreateRestaurants do
  use Ecto.Migration

  def change do
    create table(:restaurants) do
      add(:name, :string)
      add(:description, :string)
      add(:location, :string)
      add(:longitude, :integer)
      add(:latitude, :integer)
      add(:logo, :string)
      add(:status, :string)
      add(:contact_person_name, :string)
      add(:contact_person_phone_number, :string)
      add(:company_id, references(:companies, on_delete: :nothing))

      timestamps()
    end
  end
end
