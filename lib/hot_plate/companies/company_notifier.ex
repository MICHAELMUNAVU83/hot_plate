defmodule HotPlate.Companies.CompanyNotifier do
  import Swoosh.Email

  alias HotPlate.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"HotPlate", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(company, url) do
    deliver(company.email, "Confirmation instructions", """

    ==============================

    Hi #{company.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a company password.
  """
  def deliver_reset_password_instructions(company, url) do
    deliver(company.email, "Reset password instructions", """

    ==============================

    Hi #{company.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a company email.
  """
  def deliver_update_email_instructions(company, url) do
    deliver(company.email, "Update email instructions", """

    ==============================

    Hi #{company.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
