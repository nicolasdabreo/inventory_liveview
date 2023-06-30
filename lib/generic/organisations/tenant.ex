defmodule MRP.Organisations.Tenant do
  use MRP, :schema

  schema "tenants" do
    field :subdomain, :string
    field :brand_color, :string
    has_one :logo, :string

    has_many :organisations, MRP.Organisations.Organisation
    has_many :owners, MRP.Organisations.Owner

    timestamps()
  end

  @doc false
  def create_changeset(tenant \\ %__MODULE__{}, attrs) do
    tenant
    |> cast(attrs, [:subdomain, :brand_color, :logo])
    |> validate_required([:subdomain])
    |> unique_constraint(:subdomain)
  end
end
