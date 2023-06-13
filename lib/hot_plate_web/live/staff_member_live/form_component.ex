defmodule HotPlateWeb.StaffMemberLive.FormComponent do
  use HotPlateWeb, :live_component

  alias HotPlate.StaffMembers

  @impl true
  def update(%{staff_member: staff_member} = assigns, socket) do
    changeset = StaffMembers.change_staff_member(staff_member)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"staff_member" => staff_member_params}, socket) do
    changeset =
      socket.assigns.staff_member
      |> StaffMembers.change_staff_member(staff_member_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"staff_member" => staff_member_params}, socket) do
    save_staff_member(socket, socket.assigns.action, staff_member_params)
  end

  defp save_staff_member(socket, :edit, staff_member_params) do
    case StaffMembers.update_staff_member(socket.assigns.staff_member, staff_member_params) do
      {:ok, _staff_member} ->
        {:noreply,
         socket
         |> put_flash(:info, "Staff member updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_staff_member(socket, :new, staff_member_params) do
    case StaffMembers.create_staff_member(staff_member_params) do
      {:ok, _staff_member} ->
        {:noreply,
         socket
         |> put_flash(:info, "Staff member created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
