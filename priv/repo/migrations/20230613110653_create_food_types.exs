defmodule HotPlate.Repo.Migrations.CreateFoodTypes do
  use Ecto.Migration

  def change do
    create table(:food_types) do
      add :type_of_food, :string
      add :type_image, :string
      add :company_id, references(:companies, on_delete: :nothing)
      add :restaurant_id, references(:restaurants, on_delete: :nothing)

      timestamps()
    end
  end
end
