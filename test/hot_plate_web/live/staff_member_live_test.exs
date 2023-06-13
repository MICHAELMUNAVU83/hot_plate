defmodule HotPlateWeb.StaffMemberLiveTest do
  use HotPlateWeb.ConnCase

  import Phoenix.LiveViewTest
  import HotPlate.StaffMembersFixtures

  @create_attrs %{
    contact: "some contact",
    first_name: "some first_name",
    last_name: "some last_name",
    profile_picture: "some profile_picture"
  }
  @update_attrs %{
    contact: "some updated contact",
    first_name: "some updated first_name",
    last_name: "some updated last_name",
    profile_picture: "some updated profile_picture"
  }
  @invalid_attrs %{contact: nil, first_name: nil, last_name: nil, profile_picture: nil}

  defp create_staff_member(_) do
    staff_member = staff_member_fixture()
    %{staff_member: staff_member}
  end

  describe "Index" do
    setup [:create_staff_member]

    test "lists all staff_members", %{conn: conn, staff_member: staff_member} do
      {:ok, _index_live, html} = live(conn, Routes.staff_member_index_path(conn, :index))

      assert html =~ "Listing Staff members"
      assert html =~ staff_member.contact
    end

    test "saves new staff_member", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.staff_member_index_path(conn, :index))

      assert index_live |> element("a", "New Staff member") |> render_click() =~
               "New Staff member"

      assert_patch(index_live, Routes.staff_member_index_path(conn, :new))

      assert index_live
             |> form("#staff_member-form", staff_member: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#staff_member-form", staff_member: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.staff_member_index_path(conn, :index))

      assert html =~ "Staff member created successfully"
      assert html =~ "some contact"
    end

    test "updates staff_member in listing", %{conn: conn, staff_member: staff_member} do
      {:ok, index_live, _html} = live(conn, Routes.staff_member_index_path(conn, :index))

      assert index_live |> element("#staff_member-#{staff_member.id} a", "Edit") |> render_click() =~
               "Edit Staff member"

      assert_patch(index_live, Routes.staff_member_index_path(conn, :edit, staff_member))

      assert index_live
             |> form("#staff_member-form", staff_member: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#staff_member-form", staff_member: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.staff_member_index_path(conn, :index))

      assert html =~ "Staff member updated successfully"
      assert html =~ "some updated contact"
    end

    test "deletes staff_member in listing", %{conn: conn, staff_member: staff_member} do
      {:ok, index_live, _html} = live(conn, Routes.staff_member_index_path(conn, :index))

      assert index_live
             |> element("#staff_member-#{staff_member.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#staff_member-#{staff_member.id}")
    end
  end

  describe "Show" do
    setup [:create_staff_member]

    test "displays staff_member", %{conn: conn, staff_member: staff_member} do
      {:ok, _show_live, html} =
        live(conn, Routes.staff_member_show_path(conn, :show, staff_member))

      assert html =~ "Show Staff member"
      assert html =~ staff_member.contact
    end

    test "updates staff_member within modal", %{conn: conn, staff_member: staff_member} do
      {:ok, show_live, _html} =
        live(conn, Routes.staff_member_show_path(conn, :show, staff_member))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Staff member"

      assert_patch(show_live, Routes.staff_member_show_path(conn, :edit, staff_member))

      assert show_live
             |> form("#staff_member-form", staff_member: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#staff_member-form", staff_member: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.staff_member_show_path(conn, :show, staff_member))

      assert html =~ "Staff member updated successfully"
      assert html =~ "some updated contact"
    end
  end
end
