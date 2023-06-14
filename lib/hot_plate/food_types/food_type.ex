defmodule HotPlate.FoodTypes.FoodType do
  use Ecto.Schema
  import Ecto.Changeset

  schema "food_types" do
    field :type_image, :string
    field :type_of_food, :string
    has_many :foods, HotPlate.Foods.Food
    belongs_to :company, HotPlate.Companies.Company
    belongs_to :restaurant, HotPlate.Restaurants.Restaurant

    timestamps()
  end

  @doc false
  def changeset(food_type, attrs) do
    food_type
    |> cast(attrs, [:type_of_food, :type_image, :company_id, :restaurant_id])
    |> validate_required([:type_of_food, :type_image, :company_id, :restaurant_id])
  end
end
