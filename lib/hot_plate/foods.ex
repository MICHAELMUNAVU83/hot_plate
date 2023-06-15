defmodule HotPlate.Foods do
  @moduledoc """
  The Foods context.
  """

  import Ecto.Query, warn: false
  alias HotPlate.Repo

  alias HotPlate.Foods.Food

  @doc """
  Returns the list of foods.

  ## Examples

      iex> list_foods()
      [%Food{}, ...]

  """
  def list_foods do
    Repo.all(Food)
    |> Repo.preload(:food_type)
    |> Repo.preload(:restaurant)
  end

  def list_foods_by_company(company_id) do
    Repo.all(from(f in Food, where: f.company_id == ^company_id))
    |> Repo.preload(:food_type)
    |> Repo.preload(:restaurant)
  end

  def list_foods_by_restaurant_and_food_type(restaurant_id, food_type_id) do
    Repo.all(
      from(f in Food, where: f.restaurant_id == ^restaurant_id and f.food_type_id == ^food_type_id)
    )
    |> Repo.preload(:food_type)
    |> Repo.preload(:restaurant)
  end

  @doc """
  Gets a single food.

  Raises `Ecto.NoResultsError` if the Food does not exist.

  ## Examples

      iex> get_food!(123)
      %Food{}

      iex> get_food!(456)
      ** (Ecto.NoResultsError)

  """
  def get_food!(id), do: Repo.get!(Food, id)

  @doc """
  Creates a food.

  ## Examples

      iex> create_food(%{field: value})
      {:ok, %Food{}}

      iex> create_food(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_food(attrs \\ %{}) do
    %Food{}
    |> Food.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a food.

  ## Examples

      iex> update_food(food, %{field: new_value})
      {:ok, %Food{}}

      iex> update_food(food, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_food(%Food{} = food, attrs) do
    food
    |> Food.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a food.

  ## Examples

      iex> delete_food(food)
      {:ok, %Food{}}

      iex> delete_food(food)
      {:error, %Ecto.Changeset{}}

  """
  def delete_food(%Food{} = food) do
    Repo.delete(food)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking food changes.

  ## Examples

      iex> change_food(food)
      %Ecto.Changeset{data: %Food{}}

  """
  def change_food(%Food{} = food, attrs \\ %{}) do
    Food.changeset(food, attrs)
  end
end
