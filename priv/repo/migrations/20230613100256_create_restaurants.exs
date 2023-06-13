defmodule HotPlate.Repo.Migrations.CreateRestaurants do
  use Ecto.Migration

  def change do
    create table(:restaurants) do
      add :name, :string
      add :description, :string
      add :location, :string
      add :longitude, :integer
      add :latitude, :integer

      timestamps()
    end
  end
end
