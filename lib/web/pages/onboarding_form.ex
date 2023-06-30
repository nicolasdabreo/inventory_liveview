defmodule Web.Pages.OnboardingForm do
  use Web, :form

  @attributes [:brand_color, :subdomain, :auth_options]
  @defaults %{auth_options: [:password]}
  @primary_key false

  embedded_schema do
    field :subdomain, :string
    field :brand_color, :string
    field :auth_options, {:array, Ecto.Enum}, values: ~w(password magic saml google)a
  end

  @spec form(:atom, map()) :: Ecto.Changeset.t()
  def form(_step, attributes \\ @defaults)

  def form(:brand, attributes) do
    %__MODULE__{}
    |> cast(attributes, @attributes)
    |> validate_required([:subdomain])
    |> validate_subdomain()
    |> to_form(as: "onboarding")
  end

  def form(:auth, attributes) do
    %__MODULE__{}
    |> cast(attributes, @attributes)
    |> validate_subset(:auth_options, ~w(password magic saml google)a)
    |> to_form(as: "onboarding")
  end

  defp validate_subdomain(changeset) do
    changeset
    |> validate_change(:subdomain, fn value, _atom ->
      if Triplex.reserved_tenant?(value) do
        [subdomain: "You cannot use this as a subdomain, please choose another"]
      else
        []
      end
    end)
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
