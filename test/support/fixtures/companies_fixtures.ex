defmodule HotPlate.CompaniesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HotPlate.Companies` context.
  """

  def unique_company_email, do: "company#{System.unique_integer()}@example.com"
  def valid_company_password, do: "hello world!"

  def valid_company_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_company_email(),
      password: valid_company_password()
    })
  end

  def company_fixture(attrs \\ %{}) do
    {:ok, company} =
      attrs
      |> valid_company_attributes()
      |> HotPlate.Companies.register_company()

    company
  end

  def extract_company_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
