defmodule HotPlateWeb.FoodLive.FormComponent do
  use HotPlateWeb, :live_component

  alias HotPlate.Foods

  @impl true
  def update(%{food: food} = assigns, socket) do
    changeset = Foods.change_food(food)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:uploaded_files, [])
     |> allow_upload(:food_image, accept: ~w(.jpg .png .jpeg), max_entries: 1)}
  end

  @impl true
  def handle_event("validate", %{"food" => food_params}, socket) do
    changeset =
      socket.assigns.food
      |> Foods.change_food(food_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end



  def handle_event("save", %{"food" => food_params}, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :food_image, fn %{path: path}, _entry ->
        dest = Path.join([:code.priv_dir(:hot_plate), "static", "uploads", Path.basename(path)])

        # The `static/uploads` directory must exist for `File.cp!/2`
        # and MyAppWeb.static_paths/0 should contain uploads to work,.
        File.cp!(path, dest)
        {:ok, "/uploads/" <> Path.basename(dest)}
      end)

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}

    new_food_params =
      Map.put(food_params, "image", List.first(uploaded_files))
      |> Map.put("company_id", socket.assigns.company.id)

    save_food(socket, socket.assigns.action, new_food_params)
  end

  defp save_food(socket, :edit, food_params) do
    case Foods.update_food(socket.assigns.food, food_params) do
      {:ok, _food} ->
        {:noreply,
         socket
         |> put_flash(:info, "Food updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :food_image, ref)}
  end

  defp save_food(socket, :new, food_params) do
    case Foods.create_food(food_params) do
      {:ok, _food} ->
        {:noreply,
         socket
         |> put_flash(:info, "Food created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
