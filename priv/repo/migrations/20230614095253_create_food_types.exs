defmodule HotPlate.Repo.Migrations.CreateFoodTypes do
  use Ecto.Migration

  def change do
    create table(:food_types) do
      add :type_of_food, :string
      add :type_image, :string

      timestamps()
    end
  end
end
