defmodule MRP.Accounts.User do
  @moduledoc false

  use MRP, :schema

  alias __MODULE__, as: User
  alias MRP.Accounts.Email
  alias MRP.Accounts.Password
  alias MRP.Accounts.Identity

  schema "users" do
    has_one :primary_email, Email, where: [tags: ["primary"]]
    has_one :notification_email, Email, where: [tags: ["notification"]]
    has_one :public_email, Email, where: [tags: ["public"]]
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

  """
  def password_registration_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [])
    |> cast_assoc(:primary_email, required: true, with: &Email.registration_changeset/2)
    |> cast_assoc(:password, required: true, with: &Password.registration_changeset/2)
  end
end
