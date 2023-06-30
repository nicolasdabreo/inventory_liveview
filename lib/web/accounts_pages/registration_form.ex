defmodule Web.Forms.RegistrationForm do
  @moduledoc """
  Form module for creating a passwordless user that can be used as a POC for
  establishing access to a tenant.
  """

  use Web, :form

  @required [:email, :password]
  @optional []
  @attributes @required ++ @optional
  @defaults %{}
  @primary_key false

  embedded_schema do
    field :email, :string
    field :password, :string
    field :password_confirmation, :string
  end

  @spec form :: Ecto.Changeset.t()
  def form(attributes \\ @defaults) do
    %__MODULE__{}
    |> cast(attributes, @attributes)
    |> validate_email()
    |> validate_password()
  end

  @spec attributes(Ecto.Changeset.t()) :: {:ok, map()} | {:error, Ecto.Changeset.t()}
  def attributes(attributes \\ @defaults) do
    attributes
    |> form()
    |> apply_action(:register)
    |> case do
      {:ok, struct} ->
        attributes =
          struct
          |> Map.from_struct()
          |> prepare_attributes()

        {:ok, attributes}

      other ->
        other
    end
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)

    # |> validate_confirmation(:password, message: "does not match password")
  end

  defp prepare_attributes(%{email: email, password: password}) do
    %{primary_email: %{email: email}, password: %{password: password}}
  end
end
