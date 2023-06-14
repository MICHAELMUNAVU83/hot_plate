defmodule HotPlateWeb.FoodTypeLive.FormComponent do
  use HotPlateWeb, :live_component

  alias HotPlate.FoodTypes

  @impl true
  def update(%{food_type: food_type} = assigns, socket) do
    changeset = FoodTypes.change_food_type(food_type)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
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
    save_food_type(socket, socket.assigns.action, food_type_params)
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
