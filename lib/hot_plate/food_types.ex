defmodule HotPlate.FoodTypes do
  @moduledoc """
  The FoodTypes context.
  """

  import Ecto.Query, warn: false
  alias HotPlate.Repo

  alias HotPlate.FoodTypes.FoodType

  @doc """
  Returns the list of food_types.

  ## Examples

      iex> list_food_types()
      [%FoodType{}, ...]

  """
  def list_food_types do
    Repo.all(FoodType)
  end

  def list_food_types_by_company(company_id) do
    Repo.all(from f in FoodType, where: f.company_id == ^company_id)
    |> Repo.preload(:restaurant)
  end


  

  @doc """
  Gets a single food_type.

  Raises `Ecto.NoResultsError` if the Food type does not exist.

  ## Examples

      iex> get_food_type!(123)
      %FoodType{}

      iex> get_food_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_food_type!(id), do: Repo.get!(FoodType, id)

  @doc """
  Creates a food_type.

  ## Examples

      iex> create_food_type(%{field: value})
      {:ok, %FoodType{}}

      iex> create_food_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_food_type(attrs \\ %{}) do
    %FoodType{}
    |> FoodType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a food_type.

  ## Examples

      iex> update_food_type(food_type, %{field: new_value})
      {:ok, %FoodType{}}

      iex> update_food_type(food_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_food_type(%FoodType{} = food_type, attrs) do
    food_type
    |> FoodType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a food_type.

  ## Examples

      iex> delete_food_type(food_type)
      {:ok, %FoodType{}}

      iex> delete_food_type(food_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_food_type(%FoodType{} = food_type) do
    Repo.delete(food_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking food_type changes.

  ## Examples

      iex> change_food_type(food_type)
      %Ecto.Changeset{data: %FoodType{}}

  """
  def change_food_type(%FoodType{} = food_type, attrs \\ %{}) do
    FoodType.changeset(food_type, attrs)
  end
end
