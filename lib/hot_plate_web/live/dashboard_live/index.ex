defmodule HotPlateWeb.DashboardLive.Index do
  use HotPlateWeb, :live_view
  alias HotPlate.Restaurants
  alias HotPlate.Companies
  alias HotPlate.FoodTypes
  alias HotPlate.Foods
  alias HotPlate.StaffMembers

  @impl true
  def mount(_params, session, socket) do
    company = Companies.get_company_by_session_token(session["company_token"])

    {:ok,
     socket
     |> assign(:restaurants, Restaurants.list_restaurants_by_company(company.id))
     |> assign(:food_types, FoodTypes.list_food_types())
     |> assign(:foods, Foods.list_foods_by_company(company.id))
     |> assign(:staff_members, StaffMembers.list_staff_members_by_company(company.id))
     |> assign(:company, company)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Dashboard")
  end
end
