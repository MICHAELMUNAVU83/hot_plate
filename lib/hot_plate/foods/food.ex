defmodule HotPlate.Foods.Food do
  use Ecto.Schema
  import Ecto.Changeset

  schema "foods" do
    field(:name, :string)
    field(:pax, :integer)
    field(:price, :integer)
    field(:ready_time, :string)
    field(:status, :string)
    field(:image, :string)
    belongs_to(:company, HotPlate.Companies.Company)

    timestamps()
  end

  @doc false
  def changeset(food, attrs) do
    food
    |> cast(attrs, [:name, :price, :ready_time, :pax, :status, :image, :company_id])
    |> validate_required([:name, :price, :ready_time, :pax, :status, :image, :company_id])
  end
end
