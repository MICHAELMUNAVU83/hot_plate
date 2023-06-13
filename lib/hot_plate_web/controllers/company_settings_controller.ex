defmodule HotPlateWeb.CompanySettingsController do
  use HotPlateWeb, :controller

  alias HotPlate.Companies
  alias HotPlateWeb.CompanyAuth

  plug :assign_email_and_password_changesets

  def edit(conn, _params) do
    render(conn, "edit.html")
  end

  def update(conn, %{"action" => "update_email"} = params) do
    %{"current_password" => password, "company" => company_params} = params
    company = conn.assigns.current_company

    case Companies.apply_company_email(company, password, company_params) do
      {:ok, applied_company} ->
        Companies.deliver_update_email_instructions(
          applied_company,
          company.email,
          &Routes.company_settings_url(conn, :confirm_email, &1)
        )

        conn
        |> put_flash(
          :info,
          "A link to confirm your email change has been sent to the new address."
        )
        |> redirect(to: Routes.company_settings_path(conn, :edit))

      {:error, changeset} ->
        render(conn, "edit.html", email_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_password"} = params) do
    %{"current_password" => password, "company" => company_params} = params
    company = conn.assigns.current_company

    case Companies.update_company_password(company, password, company_params) do
      {:ok, company} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> put_session(:company_return_to, Routes.company_settings_path(conn, :edit))
        |> CompanyAuth.log_in_company(company)

      {:error, changeset} ->
        render(conn, "edit.html", password_changeset: changeset)
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Companies.update_company_email(conn.assigns.current_company, token) do
      :ok ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: Routes.company_settings_path(conn, :edit))

      :error ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: Routes.company_settings_path(conn, :edit))
    end
  end

  defp assign_email_and_password_changesets(conn, _opts) do
    company = conn.assigns.current_company

    conn
    |> assign(:email_changeset, Companies.change_company_email(company))
    |> assign(:password_changeset, Companies.change_company_password(company))
  end
end
