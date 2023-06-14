defmodule HotPlateWeb.CustomerRestaurantLive.Show do
  use HotPlateWeb, :live_view

  alias HotPlate.Restaurants

  @impl true
  def mount(_params, _session, socket) do
    IO.puts("mounting")
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:restaurant, Restaurants.get_restaurant!(id))}
  end
end
