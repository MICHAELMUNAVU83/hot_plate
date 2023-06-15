defmodule HotPlateWeb.CustomerRestaurantLive.Index do
  use HotPlateWeb, :live_view

  alias HotPlate.Restaurants
  alias HotPlate.FoodTypes

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:restaurant, Restaurants.get_restaurant!(id))
     |> assign(:food_types, FoodTypes.list_food_types())}
  end
end
