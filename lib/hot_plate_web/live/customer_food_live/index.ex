defmodule HotPlateWeb.CustomerFoodLive.Index do
  use HotPlateWeb, :live_view
  alias HotPlate.Restaurants
  alias HotPlate.Foods

  @impl true
  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign(:restaurants, Restaurants.list_restaurants())}
  end

  @impl true

  def handle_params(%{"id" => id, "food_type_id" => food_type_id}, _url, socket) do
    {:noreply,
     socket
     |> assign(:foods, Foods.list_foods_by_restaurant_and_food_type(id, food_type_id))}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Restaurants")
  end
end
