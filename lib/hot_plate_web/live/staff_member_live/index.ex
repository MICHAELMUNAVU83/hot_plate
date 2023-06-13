defmodule HotPlateWeb.StaffMemberLive.Index do
  use HotPlateWeb, :live_view

  alias HotPlate.StaffMembers
  alias HotPlate.StaffMembers.StaffMember
  alias HotPlate.Companies

  @impl true
  def mount(_params, session, socket) do
    company = Companies.get_company_by_session_token(session["company_token"])
    {:ok, socket |> assign(:company, company) |> assign(:staff_members, list_staff_members())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Staff member")
    |> assign(:staff_member, StaffMembers.get_staff_member!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Staff member")
    |> assign(:staff_member, %StaffMember{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Staff members")
    |> assign(:staff_member, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    staff_member = StaffMembers.get_staff_member!(id)
    {:ok, _} = StaffMembers.delete_staff_member(staff_member)

    {:noreply, assign(socket, :staff_members, list_staff_members())}
  end

  defp list_staff_members do
    StaffMembers.list_staff_members()
  end
end
