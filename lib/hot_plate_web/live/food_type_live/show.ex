defmodule HotPlateWeb.FoodTypeLive.Show do
  use HotPlateWeb, :live_view

  alias HotPlate.FoodTypes

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:food_type, FoodTypes.get_food_type!(id))}
  end

  defp page_title(:show), do: "Show Food type"
  defp page_title(:edit), do: "Edit Food type"
end
