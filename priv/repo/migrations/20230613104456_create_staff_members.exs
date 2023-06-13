defmodule HotPlate.Repo.Migrations.CreateStaffMembers do
  use Ecto.Migration

  def change do
    create table(:staff_members) do
      add(:first_name, :string)
      add(:last_name, :string)
      add(:profile_picture, :string)
      add(:contact, :string)
      add(:status, :string)
      add(:company_id, references(:companies, on_delete: :nothing))
      add(:restaurant_id, references(:restaurants, on_delete: :nothing))

      timestamps()
    end
  end
end
