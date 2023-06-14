defmodule HotPlate.FoodTypes.FoodType do
  use Ecto.Schema
  import Ecto.Changeset

  schema "food_types" do
    field(:type_image, :string)
    field(:type_of_food, :string)
    has_many(:foods, HotPlate.Foods.Food, on_delete: :delete_all)

    timestamps()
  end

  @doc false
  def changeset(food_type, attrs) do
    food_type
    |> cast(attrs, [:type_of_food, :type_image])
    |> validate_required([:type_of_food, :type_image])
  end
end
