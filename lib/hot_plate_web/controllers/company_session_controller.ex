defmodule HotPlateWeb.CompanySessionController do
  use HotPlateWeb, :controller

  alias HotPlate.Companies
  alias HotPlateWeb.CompanyAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"company" => company_params}) do
    %{"email" => email, "password" => password} = company_params

    if company = Companies.get_company_by_email_and_password(email, password) do
      CompanyAuth.log_in_company(conn, company, company_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, "new.html", error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> CompanyAuth.log_out_company()
  end
end
