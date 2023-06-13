defmodule HotPlateWeb.RestaurantLive.FormComponent do
  use HotPlateWeb, :live_component

  alias HotPlate.Restaurants

  @impl true
  def update(%{restaurant: restaurant} = assigns, socket) do
    changeset = Restaurants.change_restaurant(restaurant)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:uploaded_files, [])
     |> allow_upload(:restaurant_logo, accept: ~w(.jpg .png .jpeg), max_entries: 1)}
  end

  @impl true
  def handle_event("validate", %{"restaurant" => restaurant_params}, socket) do
    changeset =
      socket.assigns.restaurant
      |> Restaurants.change_restaurant(restaurant_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"restaurant" => restaurant_params}, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :image, fn %{path: path}, _entry ->
        dest = Path.join([:code.priv_dir(:art_store), "static", "uploads", Path.basename(path)])

        # The `static/uploads` directory must exist for `File.cp!/2`
        # and MyAppWeb.static_paths/0 should contain uploads to work,.
        File.cp!(path, dest)
        {:ok, "/uploads/" <> Path.basename(dest)}
      end)

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
    new_restaurant_params = Map.put(restaurant_params, "logo", List.first(uploaded_files))
    save_restaurant(socket, socket.assigns.action, new_restaurant_params)
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :restaurant_logo, ref)}
  end

  defp save_restaurant(socket, :edit, restaurant_params) do
    case Restaurants.update_restaurant(socket.assigns.restaurant, restaurant_params) do
      {:ok, _restaurant} ->
        {:noreply,
         socket
         |> put_flash(:info, "Restaurant updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_restaurant(socket, :new, restaurant_params) do
    case Restaurants.create_restaurant(restaurant_params) do
      {:ok, _restaurant} ->
        {:noreply,
         socket
         |> put_flash(:info, "Restaurant created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
