defmodule MRP.Accounts.Password do
  use MRP, :schema

  schema "credentials" do
    field :hashed_password, :string, source: :value
    field :type, Ecto.Enum, values: [:password]
    belongs_to :user, MRP.Accounts.User

    timestamps()
  end

  @doc """
  Changeset for creating a password based credential.
  """
  def registration_changeset(password, params \\ %{}) do
    password
    |> put_change(:type, :password)
    |> assoc_constraint(:user)
    |> hash_password(params)
  end

  defp hash_password(%Ecto.Changeset{valid?: true} = changeset, %{password: password}) do
    changeset
    |> validate_length(:password, max: 72, count: :bytes)
    |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
  end

  defp hash_password(changeset, _params), do: changeset

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%__MODULE__{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_struct, _value) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current credential otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end
end
