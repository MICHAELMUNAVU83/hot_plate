defmodule HotPlateWeb.CompanySessionControllerTest do
  use HotPlateWeb.ConnCase

  import HotPlate.CompaniesFixtures

  setup do
    %{company: company_fixture()}
  end

  describe "GET /companies/log_in" do
    test "renders log in page", %{conn: conn} do
      conn = get(conn, Routes.company_session_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Log in</h1>"
      assert response =~ "Register</a>"
      assert response =~ "Forgot your password?</a>"
    end

    test "redirects if already logged in", %{conn: conn, company: company} do
      conn = conn |> log_in_company(company) |> get(Routes.company_session_path(conn, :new))
      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /companies/log_in" do
    test "logs the company in", %{conn: conn, company: company} do
      conn =
        post(conn, Routes.company_session_path(conn, :create), %{
          "company" => %{"email" => company.email, "password" => valid_company_password()}
        })

      assert get_session(conn, :company_token)
      assert redirected_to(conn) == "/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ company.email
      assert response =~ "Settings</a>"
      assert response =~ "Log out</a>"
    end

    test "logs the company in with remember me", %{conn: conn, company: company} do
      conn =
        post(conn, Routes.company_session_path(conn, :create), %{
          "company" => %{
            "email" => company.email,
            "password" => valid_company_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_hot_plate_web_company_remember_me"]
      assert redirected_to(conn) == "/"
    end

    test "logs the company in with return to", %{conn: conn, company: company} do
      conn =
        conn
        |> init_test_session(company_return_to: "/foo/bar")
        |> post(Routes.company_session_path(conn, :create), %{
          "company" => %{
            "email" => company.email,
            "password" => valid_company_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
    end

    test "emits error message with invalid credentials", %{conn: conn, company: company} do
      conn =
        post(conn, Routes.company_session_path(conn, :create), %{
          "company" => %{"email" => company.email, "password" => "invalid_password"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Log in</h1>"
      assert response =~ "Invalid email or password"
    end
  end

  describe "DELETE /companies/log_out" do
    test "logs the company out", %{conn: conn, company: company} do
      conn = conn |> log_in_company(company) |> delete(Routes.company_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :company_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the company is not logged in", %{conn: conn} do
      conn = delete(conn, Routes.company_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :company_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end
  end
end
