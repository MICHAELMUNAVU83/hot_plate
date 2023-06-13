defmodule HotPlate.StaffMembersTest do
  use HotPlate.DataCase

  alias HotPlate.StaffMembers

  describe "staff_members" do
    alias HotPlate.StaffMembers.StaffMember

    import HotPlate.StaffMembersFixtures

    @invalid_attrs %{contact: nil, first_name: nil, last_name: nil, profile_picture: nil}

    test "list_staff_members/0 returns all staff_members" do
      staff_member = staff_member_fixture()
      assert StaffMembers.list_staff_members() == [staff_member]
    end

    test "get_staff_member!/1 returns the staff_member with given id" do
      staff_member = staff_member_fixture()
      assert StaffMembers.get_staff_member!(staff_member.id) == staff_member
    end

    test "create_staff_member/1 with valid data creates a staff_member" do
      valid_attrs = %{
        contact: "some contact",
        first_name: "some first_name",
        last_name: "some last_name",
        profile_picture: "some profile_picture"
      }

      assert {:ok, %StaffMember{} = staff_member} = StaffMembers.create_staff_member(valid_attrs)
      assert staff_member.contact == "some contact"
      assert staff_member.first_name == "some first_name"
      assert staff_member.last_name == "some last_name"
      assert staff_member.profile_picture == "some profile_picture"
    end

    test "create_staff_member/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = StaffMembers.create_staff_member(@invalid_attrs)
    end

    test "update_staff_member/2 with valid data updates the staff_member" do
      staff_member = staff_member_fixture()

      update_attrs = %{
        contact: "some updated contact",
        first_name: "some updated first_name",
        last_name: "some updated last_name",
        profile_picture: "some updated profile_picture"
      }

      assert {:ok, %StaffMember{} = staff_member} =
               StaffMembers.update_staff_member(staff_member, update_attrs)

      assert staff_member.contact == "some updated contact"
      assert staff_member.first_name == "some updated first_name"
      assert staff_member.last_name == "some updated last_name"
      assert staff_member.profile_picture == "some updated profile_picture"
    end

    test "update_staff_member/2 with invalid data returns error changeset" do
      staff_member = staff_member_fixture()

      assert {:error, %Ecto.Changeset{}} =
               StaffMembers.update_staff_member(staff_member, @invalid_attrs)

      assert staff_member == StaffMembers.get_staff_member!(staff_member.id)
    end

    test "delete_staff_member/1 deletes the staff_member" do
      staff_member = staff_member_fixture()
      assert {:ok, %StaffMember{}} = StaffMembers.delete_staff_member(staff_member)
      assert_raise Ecto.NoResultsError, fn -> StaffMembers.get_staff_member!(staff_member.id) end
    end

    test "change_staff_member/1 returns a staff_member changeset" do
      staff_member = staff_member_fixture()
      assert %Ecto.Changeset{} = StaffMembers.change_staff_member(staff_member)
    end
  end
end
