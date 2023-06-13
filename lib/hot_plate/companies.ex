defmodule HotPlate.Companies do
  @moduledoc """
  The Companies context.
  """

  import Ecto.Query, warn: false
  alias HotPlate.Repo

  alias HotPlate.Companies.{Company, CompanyToken, CompanyNotifier}

  ## Database getters

  @doc """
  Gets a company by email.

  ## Examples

      iex> get_company_by_email("foo@example.com")
      %Company{}

      iex> get_company_by_email("unknown@example.com")
      nil

  """
  def get_company_by_email(email) when is_binary(email) do
    Repo.get_by(Company, email: email)
  end

  @doc """
  Gets a company by email and password.

  ## Examples

      iex> get_company_by_email_and_password("foo@example.com", "correct_password")
      %Company{}

      iex> get_company_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_company_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    company = Repo.get_by(Company, email: email)
    if Company.valid_password?(company, password), do: company
  end

  @doc """
  Gets a single company.

  Raises `Ecto.NoResultsError` if the Company does not exist.

  ## Examples

      iex> get_company!(123)
      %Company{}

      iex> get_company!(456)
      ** (Ecto.NoResultsError)

  """
  def get_company!(id), do: Repo.get!(Company, id)

  ## Company registration

  @doc """
  Registers a company.

  ## Examples

      iex> register_company(%{field: value})
      {:ok, %Company{}}

      iex> register_company(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_company(attrs) do
    %Company{}
    |> Company.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking company changes.

  ## Examples

      iex> change_company_registration(company)
      %Ecto.Changeset{data: %Company{}}

  """
  def change_company_registration(%Company{} = company, attrs \\ %{}) do
    Company.registration_changeset(company, attrs, hash_password: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the company email.

  ## Examples

      iex> change_company_email(company)
      %Ecto.Changeset{data: %Company{}}

  """
  def change_company_email(company, attrs \\ %{}) do
    Company.email_changeset(company, attrs)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_company_email(company, "valid password", %{email: ...})
      {:ok, %Company{}}

      iex> apply_company_email(company, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_company_email(company, password, attrs) do
    company
    |> Company.email_changeset(attrs)
    |> Company.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the company email using the given token.

  If the token matches, the company email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_company_email(company, token) do
    context = "change:#{company.email}"

    with {:ok, query} <- CompanyToken.verify_change_email_token_query(token, context),
         %CompanyToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(company_email_multi(company, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp company_email_multi(company, email, context) do
    changeset =
      company
      |> Company.email_changeset(%{email: email})
      |> Company.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:company, changeset)
    |> Ecto.Multi.delete_all(:tokens, CompanyToken.company_and_contexts_query(company, [context]))
  end

  @doc """
  Delivers the update email instructions to the given company.

  ## Examples

      iex> deliver_update_email_instructions(company, current_email, &Routes.company_update_email_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_update_email_instructions(%Company{} = company, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, company_token} = CompanyToken.build_email_token(company, "change:#{current_email}")

    Repo.insert!(company_token)
    CompanyNotifier.deliver_update_email_instructions(company, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the company password.

  ## Examples

      iex> change_company_password(company)
      %Ecto.Changeset{data: %Company{}}

  """
  def change_company_password(company, attrs \\ %{}) do
    Company.password_changeset(company, attrs, hash_password: false)
  end

  @doc """
  Updates the company password.

  ## Examples

      iex> update_company_password(company, "valid password", %{password: ...})
      {:ok, %Company{}}

      iex> update_company_password(company, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_company_password(company, password, attrs) do
    changeset =
      company
      |> Company.password_changeset(attrs)
      |> Company.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:company, changeset)
    |> Ecto.Multi.delete_all(:tokens, CompanyToken.company_and_contexts_query(company, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{company: company}} -> {:ok, company}
      {:error, :company, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_company_session_token(company) do
    {token, company_token} = CompanyToken.build_session_token(company)
    Repo.insert!(company_token)
    token
  end

  @doc """
  Gets the company with the given signed token.
  """
  def get_company_by_session_token(token) do
    {:ok, query} = CompanyToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_session_token(token) do
    Repo.delete_all(CompanyToken.token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc """
  Delivers the confirmation email instructions to the given company.

  ## Examples

      iex> deliver_company_confirmation_instructions(company, &Routes.company_confirmation_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_company_confirmation_instructions(confirmed_company, &Routes.company_confirmation_url(conn, :edit, &1))
      {:error, :already_confirmed}

  """
  def deliver_company_confirmation_instructions(%Company{} = company, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if company.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, company_token} = CompanyToken.build_email_token(company, "confirm")
      Repo.insert!(company_token)
      CompanyNotifier.deliver_confirmation_instructions(company, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a company by the given token.

  If the token matches, the company account is marked as confirmed
  and the token is deleted.
  """
  def confirm_company(token) do
    with {:ok, query} <- CompanyToken.verify_email_token_query(token, "confirm"),
         %Company{} = company <- Repo.one(query),
         {:ok, %{company: company}} <- Repo.transaction(confirm_company_multi(company)) do
      {:ok, company}
    else
      _ -> :error
    end
  end

  defp confirm_company_multi(company) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:company, Company.confirm_changeset(company))
    |> Ecto.Multi.delete_all(:tokens, CompanyToken.company_and_contexts_query(company, ["confirm"]))
  end

  ## Reset password

  @doc """
  Delivers the reset password email to the given company.

  ## Examples

      iex> deliver_company_reset_password_instructions(company, &Routes.company_reset_password_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_company_reset_password_instructions(%Company{} = company, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, company_token} = CompanyToken.build_email_token(company, "reset_password")
    Repo.insert!(company_token)
    CompanyNotifier.deliver_reset_password_instructions(company, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the company by reset password token.

  ## Examples

      iex> get_company_by_reset_password_token("validtoken")
      %Company{}

      iex> get_company_by_reset_password_token("invalidtoken")
      nil

  """
  def get_company_by_reset_password_token(token) do
    with {:ok, query} <- CompanyToken.verify_email_token_query(token, "reset_password"),
         %Company{} = company <- Repo.one(query) do
      company
    else
      _ -> nil
    end
  end

  @doc """
  Resets the company password.

  ## Examples

      iex> reset_company_password(company, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %Company{}}

      iex> reset_company_password(company, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_company_password(company, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:company, Company.password_changeset(company, attrs))
    |> Ecto.Multi.delete_all(:tokens, CompanyToken.company_and_contexts_query(company, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{company: company}} -> {:ok, company}
      {:error, :company, changeset, _} -> {:error, changeset}
    end
  end
end
