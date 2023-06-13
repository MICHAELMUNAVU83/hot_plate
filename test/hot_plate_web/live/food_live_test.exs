defmodule HotPlateWeb.FoodLiveTest do
  use HotPlateWeb.ConnCase

  import Phoenix.LiveViewTest
  import HotPlate.FoodsFixtures

  @create_attrs %{name: "some name", pax: 42, price: 42, ready_time: "some ready_time", status: "some status"}
  @update_attrs %{name: "some updated name", pax: 43, price: 43, ready_time: "some updated ready_time", status: "some updated status"}
  @invalid_attrs %{name: nil, pax: nil, price: nil, ready_time: nil, status: nil}

  defp create_food(_) do
    food = food_fixture()
    %{food: food}
  end

  describe "Index" do
    setup [:create_food]

    test "lists all foods", %{conn: conn, food: food} do
      {:ok, _index_live, html} = live(conn, Routes.food_index_path(conn, :index))

      assert html =~ "Listing Foods"
      assert html =~ food.name
    end

    test "saves new food", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.food_index_path(conn, :index))

      assert index_live |> element("a", "New Food") |> render_click() =~
               "New Food"

      assert_patch(index_live, Routes.food_index_path(conn, :new))

      assert index_live
             |> form("#food-form", food: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#food-form", food: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.food_index_path(conn, :index))

      assert html =~ "Food created successfully"
      assert html =~ "some name"
    end

    test "updates food in listing", %{conn: conn, food: food} do
      {:ok, index_live, _html} = live(conn, Routes.food_index_path(conn, :index))

      assert index_live |> element("#food-#{food.id} a", "Edit") |> render_click() =~
               "Edit Food"

      assert_patch(index_live, Routes.food_index_path(conn, :edit, food))

      assert index_live
             |> form("#food-form", food: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#food-form", food: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.food_index_path(conn, :index))

      assert html =~ "Food updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes food in listing", %{conn: conn, food: food} do
      {:ok, index_live, _html} = live(conn, Routes.food_index_path(conn, :index))

      assert index_live |> element("#food-#{food.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#food-#{food.id}")
    end
  end

  describe "Show" do
    setup [:create_food]

    test "displays food", %{conn: conn, food: food} do
      {:ok, _show_live, html} = live(conn, Routes.food_show_path(conn, :show, food))

      assert html =~ "Show Food"
      assert html =~ food.name
    end

    test "updates food within modal", %{conn: conn, food: food} do
      {:ok, show_live, _html} = live(conn, Routes.food_show_path(conn, :show, food))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Food"

      assert_patch(show_live, Routes.food_show_path(conn, :edit, food))

      assert show_live
             |> form("#food-form", food: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#food-form", food: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.food_show_path(conn, :show, food))

      assert html =~ "Food updated successfully"
      assert html =~ "some updated name"
    end
  end
end
