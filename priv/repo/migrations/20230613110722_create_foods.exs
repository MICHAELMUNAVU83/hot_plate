defmodule HotPlate.Repo.Migrations.CreateFoods do
  use Ecto.Migration

  def change do
    create table(:foods) do
      add(:name, :string)
      add(:price, :integer)
      add(:ready_time, :string)
      add(:pax, :integer)
      add(:status, :string)
      add(:image, :string)
      add(:company_id, references(:companies, on_delete: :nothing))
      add(:restaurant_id, references(:restaurants, on_delete: :nothing))
      add(:food_type_id, references(:food_types, on_delete: :nothing))

      timestamps()
    end
  end
end
