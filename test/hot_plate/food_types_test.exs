defmodule HotPlate.FoodTypesTest do
  use HotPlate.DataCase

  alias HotPlate.FoodTypes

  describe "food_types" do
    alias HotPlate.FoodTypes.FoodType

    import HotPlate.FoodTypesFixtures

    @invalid_attrs %{type_image: nil, type_of_food: nil}

    test "list_food_types/0 returns all food_types" do
      food_type = food_type_fixture()
      assert FoodTypes.list_food_types() == [food_type]
    end

    test "get_food_type!/1 returns the food_type with given id" do
      food_type = food_type_fixture()
      assert FoodTypes.get_food_type!(food_type.id) == food_type
    end

    test "create_food_type/1 with valid data creates a food_type" do
      valid_attrs = %{type_image: "some type_image", type_of_food: "some type_of_food"}

      assert {:ok, %FoodType{} = food_type} = FoodTypes.create_food_type(valid_attrs)
      assert food_type.type_image == "some type_image"
      assert food_type.type_of_food == "some type_of_food"
    end

    test "create_food_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = FoodTypes.create_food_type(@invalid_attrs)
    end

    test "update_food_type/2 with valid data updates the food_type" do
      food_type = food_type_fixture()

      update_attrs = %{
        type_image: "some updated type_image",
        type_of_food: "some updated type_of_food"
      }

      assert {:ok, %FoodType{} = food_type} = FoodTypes.update_food_type(food_type, update_attrs)
      assert food_type.type_image == "some updated type_image"
      assert food_type.type_of_food == "some updated type_of_food"
    end

    test "update_food_type/2 with invalid data returns error changeset" do
      food_type = food_type_fixture()
      assert {:error, %Ecto.Changeset{}} = FoodTypes.update_food_type(food_type, @invalid_attrs)
      assert food_type == FoodTypes.get_food_type!(food_type.id)
    end

    test "delete_food_type/1 deletes the food_type" do
      food_type = food_type_fixture()
      assert {:ok, %FoodType{}} = FoodTypes.delete_food_type(food_type)
      assert_raise Ecto.NoResultsError, fn -> FoodTypes.get_food_type!(food_type.id) end
    end

    test "change_food_type/1 returns a food_type changeset" do
      food_type = food_type_fixture()
      assert %Ecto.Changeset{} = FoodTypes.change_food_type(food_type)
    end
  end
end
