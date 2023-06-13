defmodule HotPlateWeb.CompanyRegistrationController do
  use HotPlateWeb, :controller

  alias HotPlate.Companies
  alias HotPlate.Companies.Company
  alias HotPlateWeb.CompanyAuth

  def new(conn, _params) do
    changeset = Companies.change_company_registration(%Company{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"company" => company_params}) do
    case Companies.register_company(company_params) do
      {:ok, company} ->
        {:ok, _} =
          Companies.deliver_company_confirmation_instructions(
            company,
            &Routes.company_confirmation_url(conn, :edit, &1)
          )

        conn
        |> put_flash(:info, "Company created successfully.")
        |> CompanyAuth.log_in_company(company)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
