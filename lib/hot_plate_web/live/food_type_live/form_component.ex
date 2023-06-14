defmodule HotPlateWeb.FoodTypeLive.FormComponent do
  use HotPlateWeb, :live_component

  alias HotPlate.FoodTypes

  @impl true
  def update(%{food_type: food_type} = assigns, socket) do
    changeset = FoodTypes.change_food_type(food_type)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:uploaded_files, [])
     |> allow_upload(:food_type_image, accept: ~w(.jpg .png .jpeg), max_entries: 1)}
  end

  @impl true
  def handle_event("validate", %{"food_type" => food_type_params}, socket) do
    changeset =
      socket.assigns.food_type
      |> FoodTypes.change_food_type(food_type_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"food_type" => food_type_params}, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :food_type_image, fn %{path: path}, _entry ->
        dest = Path.join([:code.priv_dir(:hot_plate), "static", "uploads", Path.basename(path)])

        # The `static/uploads` directory must exist for `File.cp!/2`
        # and MyAppWeb.static_paths/0 should contain uploads to work,.
        File.cp!(path, dest)
        {:ok, "/uploads/" <> Path.basename(dest)}
      end)

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}

    new_food_type_params = Map.put(food_type_params, "type_image", List.first(uploaded_files))

    save_food_type(socket, socket.assigns.action, new_food_type_params)
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :food_type_image, ref)}
  end

  defp save_food_type(socket, :edit, food_type_params) do
    case FoodTypes.update_food_type(socket.assigns.food_type, food_type_params) do
      {:ok, _food_type} ->
        {:noreply,
         socket
         |> put_flash(:info, "Food type updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_food_type(socket, :new, food_type_params) do
    case FoodTypes.create_food_type(food_type_params) do
      {:ok, _food_type} ->
        {:noreply,
         socket
         |> put_flash(:info, "Food type created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
