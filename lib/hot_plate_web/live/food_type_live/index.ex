defmodule HotPlateWeb.FoodTypeLive.Index do
  use HotPlateWeb, :live_view

  alias HotPlate.FoodTypes
  alias HotPlate.FoodTypes.FoodType
  alias HotPlate.Companies
  alias HotPlate.Restaurants

  @impl true
  def mount(_params, session, socket) do
    company = Companies.get_company_by_session_token(session["company_token"])

    {:ok,
     socket
     |> assign(:company, company)
     |> assign(:food_types, FoodTypes.list_food_types_by_company(company.id))
     |> assign(
       :restaurants,
       Restaurants.list_restaurants()
       |> Enum.map(fn restaurant -> {restaurant.name, restaurant.id} end)
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Food type")
    |> assign(:food_type, FoodTypes.get_food_type!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Food type")
    |> assign(:food_type, %FoodType{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Food types")
    |> assign(:food_type, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    food_type = FoodTypes.get_food_type!(id)
    {:ok, _} = FoodTypes.delete_food_type(food_type)
    company = socket.assigns.company

    {:noreply, assign(socket, :food_types, FoodTypes.list_food_types_by_company(company.id))}
  end

  defp list_food_types do
    FoodTypes.list_food_types()
  end
end
