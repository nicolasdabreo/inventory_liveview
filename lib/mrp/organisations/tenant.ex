defmodule MRP.Organisations.Tenant do
  use MRP, :schema

  schema "tenants" do
    field :name, :string

    has_many :organisations, MRP.Organisations.Organisation
    has_many :owners, MRP.Organisations.Owner

    timestamps()
  end

  @doc false
  def create_changeset(tenant \\ %__MODULE__{}, attrs) do
    tenant
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
