defmodule HotPlate.Repo.Migrations.CreateStaffMembers do
  use Ecto.Migration

  def change do
    create table(:staff_members) do
      add :first_name, :string
      add :last_name, :string
      add :profile_picture, :string
      add :contact, :string

      timestamps()
    end
  end
end
