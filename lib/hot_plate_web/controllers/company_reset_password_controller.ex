defmodule HotPlateWeb.CompanyResetPasswordController do
  use HotPlateWeb, :controller

  alias HotPlate.Companies

  plug :get_company_by_reset_password_token when action in [:edit, :update]

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"company" => %{"email" => email}}) do
    if company = Companies.get_company_by_email(email) do
      Companies.deliver_company_reset_password_instructions(
        company,
        &Routes.company_reset_password_url(conn, :edit, &1)
      )
    end

    conn
    |> put_flash(
      :info,
      "If your email is in our system, you will receive instructions to reset your password shortly."
    )
    |> redirect(to: "/")
  end

  def edit(conn, _params) do
    render(conn, "edit.html", changeset: Companies.change_company_password(conn.assigns.company))
  end

  # Do not log in the company after reset password to avoid a
  # leaked token giving the company access to the account.
  def update(conn, %{"company" => company_params}) do
    case Companies.reset_company_password(conn.assigns.company, company_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Password reset successfully.")
        |> redirect(to: Routes.company_session_path(conn, :new))

      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  defp get_company_by_reset_password_token(conn, _opts) do
    %{"token" => token} = conn.params

    if company = Companies.get_company_by_reset_password_token(token) do
      conn |> assign(:company, company) |> assign(:token, token)
    else
      conn
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
