defmodule MRP.Accounts.Password do
  use MRP, :schema

  @derive {Inspect, except: [:password]}
  schema "credentials" do
    field :hashed_password, :string, source: :value
    field :password, :string, virtual: true
    field :type, Ecto.Enum, values: [:password]
    belongs_to :user, MRP.Accounts.User

    timestamps()
  end

  @doc """
  Changeset for creating a password based password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.

  """
  def registration_changeset(identity, params \\ %{}, opts \\ []) do
    identity
    |> cast(params, [:password])
    |> validate_password(opts)
    |> put_change(:type, :password)
    |> assoc_constraint(:user)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)
    |> validate_confirmation(:password, message: "does not match password")
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      |> validate_length(:password, max: 72, count: :bytes)
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

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
