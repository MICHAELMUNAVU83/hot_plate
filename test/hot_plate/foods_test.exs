defmodule HotPlate.FoodsTest do
  use HotPlate.DataCase

  alias HotPlate.Foods

  describe "foods" do
    alias HotPlate.Foods.Food

    import HotPlate.FoodsFixtures

    @invalid_attrs %{name: nil, pax: nil, price: nil, ready_time: nil, status: nil}

    test "list_foods/0 returns all foods" do
      food = food_fixture()
      assert Foods.list_foods() == [food]
    end

    test "get_food!/1 returns the food with given id" do
      food = food_fixture()
      assert Foods.get_food!(food.id) == food
    end

    test "create_food/1 with valid data creates a food" do
      valid_attrs = %{name: "some name", pax: 42, price: 42, ready_time: "some ready_time", status: "some status"}

      assert {:ok, %Food{} = food} = Foods.create_food(valid_attrs)
      assert food.name == "some name"
      assert food.pax == 42
      assert food.price == 42
      assert food.ready_time == "some ready_time"
      assert food.status == "some status"
    end

    test "create_food/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Foods.create_food(@invalid_attrs)
    end

    test "update_food/2 with valid data updates the food" do
      food = food_fixture()
      update_attrs = %{name: "some updated name", pax: 43, price: 43, ready_time: "some updated ready_time", status: "some updated status"}

      assert {:ok, %Food{} = food} = Foods.update_food(food, update_attrs)
      assert food.name == "some updated name"
      assert food.pax == 43
      assert food.price == 43
      assert food.ready_time == "some updated ready_time"
      assert food.status == "some updated status"
    end

    test "update_food/2 with invalid data returns error changeset" do
      food = food_fixture()
      assert {:error, %Ecto.Changeset{}} = Foods.update_food(food, @invalid_attrs)
      assert food == Foods.get_food!(food.id)
    end

    test "delete_food/1 deletes the food" do
      food = food_fixture()
      assert {:ok, %Food{}} = Foods.delete_food(food)
      assert_raise Ecto.NoResultsError, fn -> Foods.get_food!(food.id) end
    end

    test "change_food/1 returns a food changeset" do
      food = food_fixture()
      assert %Ecto.Changeset{} = Foods.change_food(food)
    end
  end
end
