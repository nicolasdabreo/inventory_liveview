defmodule MRP.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MRP.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> MRP.Accounts.register_user()

    user
  end

  def extractable_user_token, do: &"[TOKEN]#{&1}[TOKEN]"

  def extract_user_token(email) do
    [_, token | _] = String.split(email.text_body, "[TOKEN]")
    token
  end
end
