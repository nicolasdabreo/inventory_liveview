defmodule MRP.Accounts.Email do
  use MRP, :schema

  @email_tags ~w(primary notifications public)

  schema "emails" do
    field :email, :string
    field :tags, {:array, :string}, default: []
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
    |> cast(attrs, [:email, :tags])
    |> put_change(:tags, ["primary"])
    |> validate_required([:email])
    |> validate_unique_email()
    |> assoc_constraint(:user)
    |> validate_subset(:tags, @email_tags)
    |> sort_array(:tags)
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
      |> cast(attrs, [:email, :tags])
      |> validate_required([:email])
      |> validate_unique_email()
      |> validate_subset(:tags, @email_tags)
      |> sort_array(:tags)

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

  defp sort_array(changeset, field), do: update_change(changeset, field, &Enum.sort(&1))
end
