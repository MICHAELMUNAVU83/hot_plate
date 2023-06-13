defmodule HotPlate.RestaurantsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HotPlate.Restaurants` context.
  """

  @doc """
  Generate a restaurant.
  """
  def restaurant_fixture(attrs \\ %{}) do
    {:ok, restaurant} =
      attrs
      |> Enum.into(%{
        description: "some description",
        latitude: 42,
        location: "some location",
        longitude: 42,
        name: "some name"
      })
      |> HotPlate.Restaurants.create_restaurant()

    restaurant
  end
end
