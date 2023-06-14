defmodule HotPlateWeb.FoodTypeLiveTest do
  use HotPlateWeb.ConnCase

  import Phoenix.LiveViewTest
  import HotPlate.FoodTypesFixtures

  @create_attrs %{type_image: "some type_image", type_of_food: "some type_of_food"}
  @update_attrs %{type_image: "some updated type_image", type_of_food: "some updated type_of_food"}
  @invalid_attrs %{type_image: nil, type_of_food: nil}

  defp create_food_type(_) do
    food_type = food_type_fixture()
    %{food_type: food_type}
  end

  describe "Index" do
    setup [:create_food_type]

    test "lists all food_types", %{conn: conn, food_type: food_type} do
      {:ok, _index_live, html} = live(conn, Routes.food_type_index_path(conn, :index))

      assert html =~ "Listing Food types"
      assert html =~ food_type.type_image
    end

    test "saves new food_type", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.food_type_index_path(conn, :index))

      assert index_live |> element("a", "New Food type") |> render_click() =~
               "New Food type"

      assert_patch(index_live, Routes.food_type_index_path(conn, :new))

      assert index_live
             |> form("#food_type-form", food_type: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#food_type-form", food_type: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.food_type_index_path(conn, :index))

      assert html =~ "Food type created successfully"
      assert html =~ "some type_image"
    end

    test "updates food_type in listing", %{conn: conn, food_type: food_type} do
      {:ok, index_live, _html} = live(conn, Routes.food_type_index_path(conn, :index))

      assert index_live |> element("#food_type-#{food_type.id} a", "Edit") |> render_click() =~
               "Edit Food type"

      assert_patch(index_live, Routes.food_type_index_path(conn, :edit, food_type))

      assert index_live
             |> form("#food_type-form", food_type: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#food_type-form", food_type: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.food_type_index_path(conn, :index))

      assert html =~ "Food type updated successfully"
      assert html =~ "some updated type_image"
    end

    test "deletes food_type in listing", %{conn: conn, food_type: food_type} do
      {:ok, index_live, _html} = live(conn, Routes.food_type_index_path(conn, :index))

      assert index_live |> element("#food_type-#{food_type.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#food_type-#{food_type.id}")
    end
  end

  describe "Show" do
    setup [:create_food_type]

    test "displays food_type", %{conn: conn, food_type: food_type} do
      {:ok, _show_live, html} = live(conn, Routes.food_type_show_path(conn, :show, food_type))

      assert html =~ "Show Food type"
      assert html =~ food_type.type_image
    end

    test "updates food_type within modal", %{conn: conn, food_type: food_type} do
      {:ok, show_live, _html} = live(conn, Routes.food_type_show_path(conn, :show, food_type))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Food type"

      assert_patch(show_live, Routes.food_type_show_path(conn, :edit, food_type))

      assert show_live
             |> form("#food_type-form", food_type: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#food_type-form", food_type: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.food_type_show_path(conn, :show, food_type))

      assert html =~ "Food type updated successfully"
      assert html =~ "some updated type_image"
    end
  end
end
