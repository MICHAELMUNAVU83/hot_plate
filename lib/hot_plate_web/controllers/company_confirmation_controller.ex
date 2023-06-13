defmodule HotPlateWeb.CompanyConfirmationController do
  use HotPlateWeb, :controller

  alias HotPlate.Companies

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"company" => %{"email" => email}}) do
    if company = Companies.get_company_by_email(email) do
      Companies.deliver_company_confirmation_instructions(
        company,
        &Routes.company_confirmation_url(conn, :edit, &1)
      )
    end

    conn
    |> put_flash(
      :info,
      "If your email is in our system and it has not been confirmed yet, " <>
        "you will receive an email with instructions shortly."
    )
    |> redirect(to: "/")
  end

  def edit(conn, %{"token" => token}) do
    render(conn, "edit.html", token: token)
  end

  # Do not log in the company after confirmation to avoid a
  # leaked token giving the company access to the account.
  def update(conn, %{"token" => token}) do
    case Companies.confirm_company(token) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Company confirmed successfully.")
        |> redirect(to: "/")

      :error ->
        # If there is a current company and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the company themselves, so we redirect without
        # a warning message.
        case conn.assigns do
          %{current_company: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            redirect(conn, to: "/")

          %{} ->
            conn
            |> put_flash(:error, "Company confirmation link is invalid or it has expired.")
            |> redirect(to: "/")
        end
    end
  end
end
