defmodule HotPlate.Restaurants.Restaurant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "restaurants" do
    field(:description, :string)
    field(:latitude, :integer)
    field(:location, :string)
    field(:longitude, :integer)
    field(:name, :string)
    field(:logo, :string)

    timestamps()
  end

  @doc false
  def changeset(restaurant, attrs) do
    restaurant
    |> cast(attrs, [:name, :description, :location, :longitude, :latitude, :logo])
    |> validate_required([:name, :description, :location, :longitude, :latitude, :logo])
  end
end
