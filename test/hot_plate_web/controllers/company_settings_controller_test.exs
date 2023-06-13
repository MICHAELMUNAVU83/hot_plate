defmodule HotPlateWeb.CompanySettingsControllerTest do
  use HotPlateWeb.ConnCase

  alias HotPlate.Companies
  import HotPlate.CompaniesFixtures

  setup :register_and_log_in_company

  describe "GET /companies/settings" do
    test "renders settings page", %{conn: conn} do
      conn = get(conn, Routes.company_settings_path(conn, :edit))
      response = html_response(conn, 200)
      assert response =~ "<h1>Settings</h1>"
    end

    test "redirects if company is not logged in" do
      conn = build_conn()
      conn = get(conn, Routes.company_settings_path(conn, :edit))
      assert redirected_to(conn) == Routes.company_session_path(conn, :new)
    end
  end

  describe "PUT /companies/settings (change password form)" do
    test "updates the company password and resets tokens", %{conn: conn, company: company} do
      new_password_conn =
        put(conn, Routes.company_settings_path(conn, :update), %{
          "action" => "update_password",
          "current_password" => valid_company_password(),
          "company" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert redirected_to(new_password_conn) == Routes.company_settings_path(conn, :edit)
      assert get_session(new_password_conn, :company_token) != get_session(conn, :company_token)
      assert get_flash(new_password_conn, :info) =~ "Password updated successfully"
      assert Companies.get_company_by_email_and_password(company.email, "new valid password")
    end

    test "does not update password on invalid data", %{conn: conn} do
      old_password_conn =
        put(conn, Routes.company_settings_path(conn, :update), %{
          "action" => "update_password",
          "current_password" => "invalid",
          "company" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      response = html_response(old_password_conn, 200)
      assert response =~ "<h1>Settings</h1>"
      assert response =~ "should be at least 12 character(s)"
      assert response =~ "does not match password"
      assert response =~ "is not valid"

      assert get_session(old_password_conn, :company_token) == get_session(conn, :company_token)
    end
  end

  describe "PUT /companies/settings (change email form)" do
    @tag :capture_log
    test "updates the company email", %{conn: conn, company: company} do
      conn =
        put(conn, Routes.company_settings_path(conn, :update), %{
          "action" => "update_email",
          "current_password" => valid_company_password(),
          "company" => %{"email" => unique_company_email()}
        })

      assert redirected_to(conn) == Routes.company_settings_path(conn, :edit)
      assert get_flash(conn, :info) =~ "A link to confirm your email"
      assert Companies.get_company_by_email(company.email)
    end

    test "does not update email on invalid data", %{conn: conn} do
      conn =
        put(conn, Routes.company_settings_path(conn, :update), %{
          "action" => "update_email",
          "current_password" => "invalid",
          "company" => %{"email" => "with spaces"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Settings</h1>"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "is not valid"
    end
  end

  describe "GET /companies/settings/confirm_email/:token" do
    setup %{company: company} do
      email = unique_company_email()

      token =
        extract_company_token(fn url ->
          Companies.deliver_update_email_instructions(%{company | email: email}, company.email, url)
        end)

      %{token: token, email: email}
    end

    test "updates the company email once", %{conn: conn, company: company, token: token, email: email} do
      conn = get(conn, Routes.company_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.company_settings_path(conn, :edit)
      assert get_flash(conn, :info) =~ "Email changed successfully"
      refute Companies.get_company_by_email(company.email)
      assert Companies.get_company_by_email(email)

      conn = get(conn, Routes.company_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.company_settings_path(conn, :edit)
      assert get_flash(conn, :error) =~ "Email change link is invalid or it has expired"
    end

    test "does not update email with invalid token", %{conn: conn, company: company} do
      conn = get(conn, Routes.company_settings_path(conn, :confirm_email, "oops"))
      assert redirected_to(conn) == Routes.company_settings_path(conn, :edit)
      assert get_flash(conn, :error) =~ "Email change link is invalid or it has expired"
      assert Companies.get_company_by_email(company.email)
    end

    test "redirects if company is not logged in", %{token: token} do
      conn = build_conn()
      conn = get(conn, Routes.company_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.company_session_path(conn, :new)
    end
  end
end
