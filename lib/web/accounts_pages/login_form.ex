defmodule Web.Forms.LoginForm do
  @moduledoc """
  Form module for handling multiple steps of the login process and translating
  the params to the underlying data structures.

  Supports:

    - Email
    - Password
    - Magic Link
    - TFA
    - SSO

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
  end

  @spec form :: Ecto.Changeset.t()
  def form(attributes \\ @defaults) do
    %__MODULE__{}
    |> cast(attributes, @attributes)
    |> to_form(as: "user")
  end

  @spec attributes(Ecto.Changeset.t()) :: {:ok, map()} | {:error, Ecto.Changeset.t()}
  def attributes(attributes \\ @defaults) do
    %__MODULE__{}
    |> cast(attributes, @attributes)
    |> apply_action(:login)
    |> case do
      {:ok, struct} -> {:ok, Map.from_struct(struct)}
      other -> other
    end
  end
end
