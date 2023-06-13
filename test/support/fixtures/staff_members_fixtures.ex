defmodule HotPlate.StaffMembersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HotPlate.StaffMembers` context.
  """

  @doc """
  Generate a staff_member.
  """
  def staff_member_fixture(attrs \\ %{}) do
    {:ok, staff_member} =
      attrs
      |> Enum.into(%{
        contact: "some contact",
        first_name: "some first_name",
        last_name: "some last_name",
        profile_picture: "some profile_picture"
      })
      |> HotPlate.StaffMembers.create_staff_member()

    staff_member
  end
end
