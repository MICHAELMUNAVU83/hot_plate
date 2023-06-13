defmodule HotPlate.StaffMembers.StaffMember do
  use Ecto.Schema
  import Ecto.Changeset

  schema "staff_members" do
    field(:contact, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:profile_picture, :string)
    field(:status, :string)
    belongs_to(:company, HotPlate.Companies.Company)

    timestamps()
  end

  @doc false
  def changeset(staff_member, attrs) do
    staff_member
    |> cast(attrs, [:first_name, :last_name, :profile_picture, :contact, :status, :company_id])
    |> validate_required([
      :first_name,
      :last_name,
      :profile_picture,
      :contact,
      :status,
      :company_id
    ])
  end
end
