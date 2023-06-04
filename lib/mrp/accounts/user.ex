defmodule MRP.Accounts.User do
  @moduledoc false

  use MRP, :schema

  alias __MODULE__, as: User
  alias MRP.Accounts.Email
  alias MRP.Accounts.Password
  alias MRP.Accounts.Identity

  schema "users" do
    has_one :primary_email, Email
    has_one :notification_email, Email
    has_many :linked_emails, Email
    has_one :password, Password
    has_many :identities, Identity

    timestamps()
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.

    * `:validate_email` - Validates the uniqueness of the email, in case
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_registration_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [])
    |> cast_assoc(:primary_email, required: true, with: &Email.registration_changeset/2)
    |> cast_assoc(:password, required: true, with: &Password.registration_changeset/2)
  end
end
