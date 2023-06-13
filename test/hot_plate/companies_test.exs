defmodule HotPlate.CompaniesTest do
  use HotPlate.DataCase

  alias HotPlate.Companies

  import HotPlate.CompaniesFixtures
  alias HotPlate.Companies.{Company, CompanyToken}

  describe "get_company_by_email/1" do
    test "does not return the company if the email does not exist" do
      refute Companies.get_company_by_email("unknown@example.com")
    end

    test "returns the company if the email exists" do
      %{id: id} = company = company_fixture()
      assert %Company{id: ^id} = Companies.get_company_by_email(company.email)
    end
  end

  describe "get_company_by_email_and_password/2" do
    test "does not return the company if the email does not exist" do
      refute Companies.get_company_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the company if the password is not valid" do
      company = company_fixture()
      refute Companies.get_company_by_email_and_password(company.email, "invalid")
    end

    test "returns the company if the email and password are valid" do
      %{id: id} = company = company_fixture()

      assert %Company{id: ^id} =
               Companies.get_company_by_email_and_password(company.email, valid_company_password())
    end
  end

  describe "get_company!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Companies.get_company!(-1)
      end
    end

    test "returns the company with the given id" do
      %{id: id} = company = company_fixture()
      assert %Company{id: ^id} = Companies.get_company!(company.id)
    end
  end

  describe "register_company/1" do
    test "requires email and password to be set" do
      {:error, changeset} = Companies.register_company(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = Companies.register_company(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Companies.register_company(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness" do
      %{email: email} = company_fixture()
      {:error, changeset} = Companies.register_company(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Companies.register_company(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers companies with a hashed password" do
      email = unique_company_email()
      {:ok, company} = Companies.register_company(valid_company_attributes(email: email))
      assert company.email == email
      assert is_binary(company.hashed_password)
      assert is_nil(company.confirmed_at)
      assert is_nil(company.password)
    end
  end

  describe "change_company_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Companies.change_company_registration(%Company{})
      assert changeset.required == [:password, :email]
    end

    test "allows fields to be set" do
      email = unique_company_email()
      password = valid_company_password()

      changeset =
        Companies.change_company_registration(
          %Company{},
          valid_company_attributes(email: email, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_company_email/2" do
    test "returns a company changeset" do
      assert %Ecto.Changeset{} = changeset = Companies.change_company_email(%Company{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_company_email/3" do
    setup do
      %{company: company_fixture()}
    end

    test "requires email to change", %{company: company} do
      {:error, changeset} = Companies.apply_company_email(company, valid_company_password(), %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{company: company} do
      {:error, changeset} =
        Companies.apply_company_email(company, valid_company_password(), %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{company: company} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Companies.apply_company_email(company, valid_company_password(), %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{company: company} do
      %{email: email} = company_fixture()

      {:error, changeset} =
        Companies.apply_company_email(company, valid_company_password(), %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{company: company} do
      {:error, changeset} =
        Companies.apply_company_email(company, "invalid", %{email: unique_company_email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{company: company} do
      email = unique_company_email()
      {:ok, company} = Companies.apply_company_email(company, valid_company_password(), %{email: email})
      assert company.email == email
      assert Companies.get_company!(company.id).email != email
    end
  end

  describe "deliver_update_email_instructions/3" do
    setup do
      %{company: company_fixture()}
    end

    test "sends token through notification", %{company: company} do
      token =
        extract_company_token(fn url ->
          Companies.deliver_update_email_instructions(company, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert company_token = Repo.get_by(CompanyToken, token: :crypto.hash(:sha256, token))
      assert company_token.company_id == company.id
      assert company_token.sent_to == company.email
      assert company_token.context == "change:current@example.com"
    end
  end

  describe "update_company_email/2" do
    setup do
      company = company_fixture()
      email = unique_company_email()

      token =
        extract_company_token(fn url ->
          Companies.deliver_update_email_instructions(%{company | email: email}, company.email, url)
        end)

      %{company: company, token: token, email: email}
    end

    test "updates the email with a valid token", %{company: company, token: token, email: email} do
      assert Companies.update_company_email(company, token) == :ok
      changed_company = Repo.get!(Company, company.id)
      assert changed_company.email != company.email
      assert changed_company.email == email
      assert changed_company.confirmed_at
      assert changed_company.confirmed_at != company.confirmed_at
      refute Repo.get_by(CompanyToken, company_id: company.id)
    end

    test "does not update email with invalid token", %{company: company} do
      assert Companies.update_company_email(company, "oops") == :error
      assert Repo.get!(Company, company.id).email == company.email
      assert Repo.get_by(CompanyToken, company_id: company.id)
    end

    test "does not update email if company email changed", %{company: company, token: token} do
      assert Companies.update_company_email(%{company | email: "current@example.com"}, token) == :error
      assert Repo.get!(Company, company.id).email == company.email
      assert Repo.get_by(CompanyToken, company_id: company.id)
    end

    test "does not update email if token expired", %{company: company, token: token} do
      {1, nil} = Repo.update_all(CompanyToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Companies.update_company_email(company, token) == :error
      assert Repo.get!(Company, company.id).email == company.email
      assert Repo.get_by(CompanyToken, company_id: company.id)
    end
  end

  describe "change_company_password/2" do
    test "returns a company changeset" do
      assert %Ecto.Changeset{} = changeset = Companies.change_company_password(%Company{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Companies.change_company_password(%Company{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_company_password/3" do
    setup do
      %{company: company_fixture()}
    end

    test "validates password", %{company: company} do
      {:error, changeset} =
        Companies.update_company_password(company, valid_company_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{company: company} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Companies.update_company_password(company, valid_company_password(), %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{company: company} do
      {:error, changeset} =
        Companies.update_company_password(company, "invalid", %{password: valid_company_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{company: company} do
      {:ok, company} =
        Companies.update_company_password(company, valid_company_password(), %{
          password: "new valid password"
        })

      assert is_nil(company.password)
      assert Companies.get_company_by_email_and_password(company.email, "new valid password")
    end

    test "deletes all tokens for the given company", %{company: company} do
      _ = Companies.generate_company_session_token(company)

      {:ok, _} =
        Companies.update_company_password(company, valid_company_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(CompanyToken, company_id: company.id)
    end
  end

  describe "generate_company_session_token/1" do
    setup do
      %{company: company_fixture()}
    end

    test "generates a token", %{company: company} do
      token = Companies.generate_company_session_token(company)
      assert company_token = Repo.get_by(CompanyToken, token: token)
      assert company_token.context == "session"

      # Creating the same token for another company should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%CompanyToken{
          token: company_token.token,
          company_id: company_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_company_by_session_token/1" do
    setup do
      company = company_fixture()
      token = Companies.generate_company_session_token(company)
      %{company: company, token: token}
    end

    test "returns company by token", %{company: company, token: token} do
      assert session_company = Companies.get_company_by_session_token(token)
      assert session_company.id == company.id
    end

    test "does not return company for invalid token" do
      refute Companies.get_company_by_session_token("oops")
    end

    test "does not return company for expired token", %{token: token} do
      {1, nil} = Repo.update_all(CompanyToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Companies.get_company_by_session_token(token)
    end
  end

  describe "delete_session_token/1" do
    test "deletes the token" do
      company = company_fixture()
      token = Companies.generate_company_session_token(company)
      assert Companies.delete_session_token(token) == :ok
      refute Companies.get_company_by_session_token(token)
    end
  end

  describe "deliver_company_confirmation_instructions/2" do
    setup do
      %{company: company_fixture()}
    end

    test "sends token through notification", %{company: company} do
      token =
        extract_company_token(fn url ->
          Companies.deliver_company_confirmation_instructions(company, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert company_token = Repo.get_by(CompanyToken, token: :crypto.hash(:sha256, token))
      assert company_token.company_id == company.id
      assert company_token.sent_to == company.email
      assert company_token.context == "confirm"
    end
  end

  describe "confirm_company/1" do
    setup do
      company = company_fixture()

      token =
        extract_company_token(fn url ->
          Companies.deliver_company_confirmation_instructions(company, url)
        end)

      %{company: company, token: token}
    end

    test "confirms the email with a valid token", %{company: company, token: token} do
      assert {:ok, confirmed_company} = Companies.confirm_company(token)
      assert confirmed_company.confirmed_at
      assert confirmed_company.confirmed_at != company.confirmed_at
      assert Repo.get!(Company, company.id).confirmed_at
      refute Repo.get_by(CompanyToken, company_id: company.id)
    end

    test "does not confirm with invalid token", %{company: company} do
      assert Companies.confirm_company("oops") == :error
      refute Repo.get!(Company, company.id).confirmed_at
      assert Repo.get_by(CompanyToken, company_id: company.id)
    end

    test "does not confirm email if token expired", %{company: company, token: token} do
      {1, nil} = Repo.update_all(CompanyToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Companies.confirm_company(token) == :error
      refute Repo.get!(Company, company.id).confirmed_at
      assert Repo.get_by(CompanyToken, company_id: company.id)
    end
  end

  describe "deliver_company_reset_password_instructions/2" do
    setup do
      %{company: company_fixture()}
    end

    test "sends token through notification", %{company: company} do
      token =
        extract_company_token(fn url ->
          Companies.deliver_company_reset_password_instructions(company, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert company_token = Repo.get_by(CompanyToken, token: :crypto.hash(:sha256, token))
      assert company_token.company_id == company.id
      assert company_token.sent_to == company.email
      assert company_token.context == "reset_password"
    end
  end

  describe "get_company_by_reset_password_token/1" do
    setup do
      company = company_fixture()

      token =
        extract_company_token(fn url ->
          Companies.deliver_company_reset_password_instructions(company, url)
        end)

      %{company: company, token: token}
    end

    test "returns the company with valid token", %{company: %{id: id}, token: token} do
      assert %Company{id: ^id} = Companies.get_company_by_reset_password_token(token)
      assert Repo.get_by(CompanyToken, company_id: id)
    end

    test "does not return the company with invalid token", %{company: company} do
      refute Companies.get_company_by_reset_password_token("oops")
      assert Repo.get_by(CompanyToken, company_id: company.id)
    end

    test "does not return the company if token expired", %{company: company, token: token} do
      {1, nil} = Repo.update_all(CompanyToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Companies.get_company_by_reset_password_token(token)
      assert Repo.get_by(CompanyToken, company_id: company.id)
    end
  end

  describe "reset_company_password/2" do
    setup do
      %{company: company_fixture()}
    end

    test "validates password", %{company: company} do
      {:error, changeset} =
        Companies.reset_company_password(company, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{company: company} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Companies.reset_company_password(company, %{password: too_long})
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{company: company} do
      {:ok, updated_company} = Companies.reset_company_password(company, %{password: "new valid password"})
      assert is_nil(updated_company.password)
      assert Companies.get_company_by_email_and_password(company.email, "new valid password")
    end

    test "deletes all tokens for the given company", %{company: company} do
      _ = Companies.generate_company_session_token(company)
      {:ok, _} = Companies.reset_company_password(company, %{password: "new valid password"})
      refute Repo.get_by(CompanyToken, company_id: company.id)
    end
  end

  describe "inspect/2" do
    test "does not include password" do
      refute inspect(%Company{password: "123456"}) =~ "password: \"123456\""
    end
  end
end
