defmodule HotPlateWeb.FoodLive.Index do
  use HotPlateWeb, :live_view

  alias HotPlate.Foods
  alias HotPlate.Foods.Food
  alias HotPlate.Companies
  alias HotPlate.Restaurants
  alias HotPlate.FoodTypes

  @impl true
  def mount(_params, session, socket) do
    company = Companies.get_company_by_session_token(session["company_token"])

    {:ok,
     socket
     |> assign(:company, company)
     |> assign(:foods, Foods.list_foods_by_company(company.id))
     |> assign(
       :restaurants,
       Restaurants.list_restaurants_by_company(company.id)
       |> Enum.map(fn restaurant -> {restaurant.name, restaurant.id} end)
     )
     |> assign(
       :food_types,
       FoodTypes.list_food_types()
       |> Enum.map(fn food_type -> {food_type.type_of_food, food_type.id} end)
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Food")
    |> assign(:food, Foods.get_food!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Food")
    |> assign(:food, %Food{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Foods")
    |> assign(:food, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    food = Foods.get_food!(id)
    {:ok, _} = Foods.delete_food(food)
    company = socket.assigns.company

    {:noreply, assign(socket, :foods, Foods.list_foods_by_company(company.id))}
  end

  defp list_foods do
    Foods.list_foods()
  end
end
