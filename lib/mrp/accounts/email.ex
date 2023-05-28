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
  def registration_changeset(email, attrs, opts \\ []) do
    email
    |> cast(attrs, [:email])
    |> validate_email(opts)
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
  def email_changeset(email \\ %__MODULE__{}, attrs, opts \\ []) do
    changeset =
      email
      |> cast(attrs, [:email])
      |> validate_email(opts)

    case changeset do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> maybe_validate_unique_email(opts)
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, MRP.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end
end
