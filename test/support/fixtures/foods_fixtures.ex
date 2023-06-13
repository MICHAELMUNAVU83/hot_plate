defmodule HotPlate.FoodsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HotPlate.Foods` context.
  """

  @doc """
  Generate a food.
  """
  def food_fixture(attrs \\ %{}) do
    {:ok, food} =
      attrs
      |> Enum.into(%{
        name: "some name",
        pax: 42,
        price: 42,
        ready_time: "some ready_time",
        status: "some status"
      })
      |> HotPlate.Foods.create_food()

    food
  end
end
