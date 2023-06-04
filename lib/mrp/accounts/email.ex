defmodule MRP.Accounts.Email do
  use MRP, :schema

  schema "emails" do
    field :email, :string
    field :verified_at, :naive_datetime
    belongs_to :user, MRP.Accounts.User

    timestamps()
  end

  @doc """
  Validates email address creation for account registration with email and
  password.
  """
  def registration_changeset(email, attrs) do
    email
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> validate_unique_email()
    |> assoc_constraint(:user)
  end

  @doc """
  Verifies the email by setting `verified_at`.
  """
  def verify_changeset(email) do
    now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
    change(email, verified_at: now)
  end

  @doc """
  Validates email address changes.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(email \\ %__MODULE__{}, attrs) do
    changeset =
      email
      |> cast(attrs, [:email])
      |> validate_required([:email])
      |> validate_unique_email()

    case changeset do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  defp validate_unique_email(changeset) do
    changeset
    |> unsafe_validate_unique(:email, MRP.Repo)
    |> unique_constraint(:email)
  end
end
