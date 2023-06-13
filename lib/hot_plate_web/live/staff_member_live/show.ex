defmodule HotPlateWeb.StaffMemberLive.Show do
  use HotPlateWeb, :live_view

  alias HotPlate.StaffMembers

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:staff_member, StaffMembers.get_staff_member!(id))}
  end

  defp page_title(:show), do: "Show Staff member"
  defp page_title(:edit), do: "Edit Staff member"
end
