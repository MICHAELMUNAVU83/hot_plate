defmodule HotPlateWeb.CustomerPageLive.Index do
  use HotPlateWeb, :live_view
  alias HotPlate.Restaurants

  @impl true
  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign(:restaurants, Restaurants.list_restaurants())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Restaurants")
  end
end
