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
    field(:status, :string)
    field(:contact_person_name, :string)
    field(:contact_person_phone_number, :string)
    belongs_to(:company, HotPlate.Companies.Company)

    timestamps()
  end

  @doc false
  def changeset(restaurant, attrs) do
    restaurant
    |> cast(attrs, [
      :name,
      :description,
      :location,
      :longitude,
      :latitude,
      :logo,
      :company_id,
      :status,
      :contact_person_name,
      :contact_person_phone_number
    ])
    |> validate_required([
      :name,
      :description,
      :location,
      :longitude,
      :latitude,
      :logo,
      :status,
      :company_id,
      :contact_person_name,
      :contact_person_phone_number
    ])
  end
end
