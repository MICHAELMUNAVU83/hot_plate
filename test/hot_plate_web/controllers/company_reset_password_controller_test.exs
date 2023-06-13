defmodule HotPlateWeb.CompanyResetPasswordControllerTest do
  use HotPlateWeb.ConnCase

  alias HotPlate.Companies
  alias HotPlate.Repo
  import HotPlate.CompaniesFixtures

  setup do
    %{company: company_fixture()}
  end

  describe "GET /companies/reset_password" do
    test "renders the reset password page", %{conn: conn} do
      conn = get(conn, Routes.company_reset_password_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Forgot your password?</h1>"
    end
  end

  describe "POST /companies/reset_password" do
    @tag :capture_log
    test "sends a new reset password token", %{conn: conn, company: company} do
      conn =
        post(conn, Routes.company_reset_password_path(conn, :create), %{
          "company" => %{"email" => company.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.get_by!(Companies.CompanyToken, company_id: company.id).context == "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.company_reset_password_path(conn, :create), %{
          "company" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.all(Companies.CompanyToken) == []
    end
  end

  describe "GET /companies/reset_password/:token" do
    setup %{company: company} do
      token =
        extract_company_token(fn url ->
          Companies.deliver_company_reset_password_instructions(company, url)
        end)

      %{token: token}
    end

    test "renders reset password", %{conn: conn, token: token} do
      conn = get(conn, Routes.company_reset_password_path(conn, :edit, token))
      assert html_response(conn, 200) =~ "<h1>Reset password</h1>"
    end

    test "does not render reset password with invalid token", %{conn: conn} do
      conn = get(conn, Routes.company_reset_password_path(conn, :edit, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Reset password link is invalid or it has expired"
    end
  end

  describe "PUT /companies/reset_password/:token" do
    setup %{company: company} do
      token =
        extract_company_token(fn url ->
          Companies.deliver_company_reset_password_instructions(company, url)
        end)

      %{token: token}
    end

    test "resets password once", %{conn: conn, company: company, token: token} do
      conn =
        put(conn, Routes.company_reset_password_path(conn, :update, token), %{
          "company" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert redirected_to(conn) == Routes.company_session_path(conn, :new)
      refute get_session(conn, :company_token)
      assert get_flash(conn, :info) =~ "Password reset successfully"
      assert Companies.get_company_by_email_and_password(company.email, "new valid password")
    end

    test "does not reset password on invalid data", %{conn: conn, token: token} do
      conn =
        put(conn, Routes.company_reset_password_path(conn, :update, token), %{
          "company" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Reset password</h1>"
      assert response =~ "should be at least 12 character(s)"
      assert response =~ "does not match password"
    end

    test "does not reset password with invalid token", %{conn: conn} do
      conn = put(conn, Routes.company_reset_password_path(conn, :update, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Reset password link is invalid or it has expired"
    end
  end
end
