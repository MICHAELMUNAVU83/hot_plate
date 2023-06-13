defmodule HotPlateWeb.CompanyAuthTest do
  use HotPlateWeb.ConnCase

  alias HotPlate.Companies
  alias HotPlateWeb.CompanyAuth
  import HotPlate.CompaniesFixtures

  @remember_me_cookie "_hot_plate_web_company_remember_me"

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, HotPlateWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{company: company_fixture(), conn: conn}
  end

  describe "log_in_company/3" do
    test "stores the company token in the session", %{conn: conn, company: company} do
      conn = CompanyAuth.log_in_company(conn, company)
      assert token = get_session(conn, :company_token)
      assert get_session(conn, :live_socket_id) == "companies_sessions:#{Base.url_encode64(token)}"
      assert redirected_to(conn) == "/"
      assert Companies.get_company_by_session_token(token)
    end

    test "clears everything previously stored in the session", %{conn: conn, company: company} do
      conn = conn |> put_session(:to_be_removed, "value") |> CompanyAuth.log_in_company(company)
      refute get_session(conn, :to_be_removed)
    end

    test "redirects to the configured path", %{conn: conn, company: company} do
      conn = conn |> put_session(:company_return_to, "/hello") |> CompanyAuth.log_in_company(company)
      assert redirected_to(conn) == "/hello"
    end

    test "writes a cookie if remember_me is configured", %{conn: conn, company: company} do
      conn = conn |> fetch_cookies() |> CompanyAuth.log_in_company(company, %{"remember_me" => "true"})
      assert get_session(conn, :company_token) == conn.cookies[@remember_me_cookie]

      assert %{value: signed_token, max_age: max_age} = conn.resp_cookies[@remember_me_cookie]
      assert signed_token != get_session(conn, :company_token)
      assert max_age == 5_184_000
    end
  end

  describe "logout_company/1" do
    test "erases session and cookies", %{conn: conn, company: company} do
      company_token = Companies.generate_company_session_token(company)

      conn =
        conn
        |> put_session(:company_token, company_token)
        |> put_req_cookie(@remember_me_cookie, company_token)
        |> fetch_cookies()
        |> CompanyAuth.log_out_company()

      refute get_session(conn, :company_token)
      refute conn.cookies[@remember_me_cookie]
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == "/"
      refute Companies.get_company_by_session_token(company_token)
    end

    test "broadcasts to the given live_socket_id", %{conn: conn} do
      live_socket_id = "companies_sessions:abcdef-token"
      HotPlateWeb.Endpoint.subscribe(live_socket_id)

      conn
      |> put_session(:live_socket_id, live_socket_id)
      |> CompanyAuth.log_out_company()

      assert_receive %Phoenix.Socket.Broadcast{event: "disconnect", topic: ^live_socket_id}
    end

    test "works even if company is already logged out", %{conn: conn} do
      conn = conn |> fetch_cookies() |> CompanyAuth.log_out_company()
      refute get_session(conn, :company_token)
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == "/"
    end
  end

  describe "fetch_current_company/2" do
    test "authenticates company from session", %{conn: conn, company: company} do
      company_token = Companies.generate_company_session_token(company)
      conn = conn |> put_session(:company_token, company_token) |> CompanyAuth.fetch_current_company([])
      assert conn.assigns.current_company.id == company.id
    end

    test "authenticates company from cookies", %{conn: conn, company: company} do
      logged_in_conn =
        conn |> fetch_cookies() |> CompanyAuth.log_in_company(company, %{"remember_me" => "true"})

      company_token = logged_in_conn.cookies[@remember_me_cookie]
      %{value: signed_token} = logged_in_conn.resp_cookies[@remember_me_cookie]

      conn =
        conn
        |> put_req_cookie(@remember_me_cookie, signed_token)
        |> CompanyAuth.fetch_current_company([])

      assert get_session(conn, :company_token) == company_token
      assert conn.assigns.current_company.id == company.id
    end

    test "does not authenticate if data is missing", %{conn: conn, company: company} do
      _ = Companies.generate_company_session_token(company)
      conn = CompanyAuth.fetch_current_company(conn, [])
      refute get_session(conn, :company_token)
      refute conn.assigns.current_company
    end
  end

  describe "redirect_if_company_is_authenticated/2" do
    test "redirects if company is authenticated", %{conn: conn, company: company} do
      conn = conn |> assign(:current_company, company) |> CompanyAuth.redirect_if_company_is_authenticated([])
      assert conn.halted
      assert redirected_to(conn) == "/"
    end

    test "does not redirect if company is not authenticated", %{conn: conn} do
      conn = CompanyAuth.redirect_if_company_is_authenticated(conn, [])
      refute conn.halted
      refute conn.status
    end
  end

  describe "require_authenticated_company/2" do
    test "redirects if company is not authenticated", %{conn: conn} do
      conn = conn |> fetch_flash() |> CompanyAuth.require_authenticated_company([])
      assert conn.halted
      assert redirected_to(conn) == Routes.company_session_path(conn, :new)
      assert get_flash(conn, :error) == "You must log in to access this page."
    end

    test "stores the path to redirect to on GET", %{conn: conn} do
      halted_conn =
        %{conn | path_info: ["foo"], query_string: ""}
        |> fetch_flash()
        |> CompanyAuth.require_authenticated_company([])

      assert halted_conn.halted
      assert get_session(halted_conn, :company_return_to) == "/foo"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar=baz"}
        |> fetch_flash()
        |> CompanyAuth.require_authenticated_company([])

      assert halted_conn.halted
      assert get_session(halted_conn, :company_return_to) == "/foo?bar=baz"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar", method: "POST"}
        |> fetch_flash()
        |> CompanyAuth.require_authenticated_company([])

      assert halted_conn.halted
      refute get_session(halted_conn, :company_return_to)
    end

    test "does not redirect if company is authenticated", %{conn: conn, company: company} do
      conn = conn |> assign(:current_company, company) |> CompanyAuth.require_authenticated_company([])
      refute conn.halted
      refute conn.status
    end
  end
end
