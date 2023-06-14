defmodule HotPlate.FoodTypesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HotPlate.FoodTypes` context.
  """

  @doc """
  Generate a food_type.
  """
  def food_type_fixture(attrs \\ %{}) do
    {:ok, food_type} =
      attrs
      |> Enum.into(%{
        type_image: "some type_image",
        type_of_food: "some type_of_food"
      })
      |> HotPlate.FoodTypes.create_food_type()

    food_type
  end
end
