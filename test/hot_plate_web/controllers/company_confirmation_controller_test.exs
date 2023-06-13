defmodule HotPlateWeb.CompanyConfirmationControllerTest do
  use HotPlateWeb.ConnCase

  alias HotPlate.Companies
  alias HotPlate.Repo
  import HotPlate.CompaniesFixtures

  setup do
    %{company: company_fixture()}
  end

  describe "GET /companies/confirm" do
    test "renders the resend confirmation page", %{conn: conn} do
      conn = get(conn, Routes.company_confirmation_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Resend confirmation instructions</h1>"
    end
  end

  describe "POST /companies/confirm" do
    @tag :capture_log
    test "sends a new confirmation token", %{conn: conn, company: company} do
      conn =
        post(conn, Routes.company_confirmation_path(conn, :create), %{
          "company" => %{"email" => company.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.get_by!(Companies.CompanyToken, company_id: company.id).context == "confirm"
    end

    test "does not send confirmation token if Company is confirmed", %{conn: conn, company: company} do
      Repo.update!(Companies.Company.confirm_changeset(company))

      conn =
        post(conn, Routes.company_confirmation_path(conn, :create), %{
          "company" => %{"email" => company.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      refute Repo.get_by(Companies.CompanyToken, company_id: company.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.company_confirmation_path(conn, :create), %{
          "company" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.all(Companies.CompanyToken) == []
    end
  end

  describe "GET /companies/confirm/:token" do
    test "renders the confirmation page", %{conn: conn} do
      conn = get(conn, Routes.company_confirmation_path(conn, :edit, "some-token"))
      response = html_response(conn, 200)
      assert response =~ "<h1>Confirm account</h1>"

      form_action = Routes.company_confirmation_path(conn, :update, "some-token")
      assert response =~ "action=\"#{form_action}\""
    end
  end

  describe "POST /companies/confirm/:token" do
    test "confirms the given token once", %{conn: conn, company: company} do
      token =
        extract_company_token(fn url ->
          Companies.deliver_company_confirmation_instructions(company, url)
        end)

      conn = post(conn, Routes.company_confirmation_path(conn, :update, token))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "Company confirmed successfully"
      assert Companies.get_company!(company.id).confirmed_at
      refute get_session(conn, :company_token)
      assert Repo.all(Companies.CompanyToken) == []

      # When not logged in
      conn = post(conn, Routes.company_confirmation_path(conn, :update, token))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Company confirmation link is invalid or it has expired"

      # When logged in
      conn =
        build_conn()
        |> log_in_company(company)
        |> post(Routes.company_confirmation_path(conn, :update, token))

      assert redirected_to(conn) == "/"
      refute get_flash(conn, :error)
    end

    test "does not confirm email with invalid token", %{conn: conn, company: company} do
      conn = post(conn, Routes.company_confirmation_path(conn, :update, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Company confirmation link is invalid or it has expired"
      refute Companies.get_company!(company.id).confirmed_at
    end
  end
end
