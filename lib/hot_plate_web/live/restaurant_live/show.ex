defmodule HotPlateWeb.RestaurantLive.Show do
  use HotPlateWeb, :live_view

  alias HotPlate.Restaurants

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:restaurant, Restaurants.get_restaurant!(id))}
  end

  defp page_title(:show), do: "Show Restaurant"
  defp page_title(:edit), do: "Edit Restaurant"
end
