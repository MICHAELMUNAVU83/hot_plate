defmodule HotPlateWeb.StaffMemberLive.FormComponent do
  use HotPlateWeb, :live_component

  alias HotPlate.StaffMembers

  @impl true
  def update(%{staff_member: staff_member} = assigns, socket) do
    changeset = StaffMembers.change_staff_member(staff_member)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:uploaded_files, [])
     |> allow_upload(:staff_photo, accept: ~w(.jpg .png .jpeg), max_entries: 1)}
  end

  @impl true
  def handle_event("validate", %{"staff_member" => staff_member_params}, socket) do
    changeset =
      socket.assigns.staff_member
      |> StaffMembers.change_staff_member(staff_member_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :staff_photo, ref)}
  end

  def handle_event("save", %{"staff_member" => staff_member_params}, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :staff_photo, fn %{path: path}, _entry ->
        dest = Path.join([:code.priv_dir(:hot_plate), "static", "uploads", Path.basename(path)])

        # The `static/uploads` directory must exist for `File.cp!/2`
        # and MyAppWeb.static_paths/0 should contain uploads to work,.
        File.cp!(path, dest)
        {:ok, "/uploads/" <> Path.basename(dest)}
      end)

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}

    new_staff_member_params =
      Map.put(staff_member_params, "profile_picture", List.first(uploaded_files))
      |> Map.put("company_id", socket.assigns.company.id)

    save_staff_member(socket, socket.assigns.action, new_staff_member_params)
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
