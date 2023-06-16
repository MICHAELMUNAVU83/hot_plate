defmodule HotPlate.Foods.Food do
  use Ecto.Schema
  import Ecto.Changeset

  schema "foods" do
    field(:name, :string)
    field(:pax, :integer)
    field(:price, :integer)
    field(:ready_time, :string)
    field(:status, :string)
    field(:image, :string)
    belongs_to(:company, HotPlate.Companies.Company)
    belongs_to(:restaurant, HotPlate.Restaurants.Restaurant)
    belongs_to(:food_type, HotPlate.FoodTypes.FoodType)

    timestamps()
  end

  @doc false
  def changeset(food, attrs) do
    food
    |> cast(attrs, [
      :name,
      :price,
      :ready_time,
      :pax,
      :status,
      :image,
      :company_id,
      :restaurant_id,
      :food_type_id
    ])
    |> validate_required([
      :name,
      :price,
      :ready_time,
      :pax,
      :status,
      :image,
      :company_id,
      :restaurant_id,
      :food_type_id
    ])
    |> validate_inclusion(:pax , 1..10 , message: "Pax must be between 1 and 10")
  end
end
