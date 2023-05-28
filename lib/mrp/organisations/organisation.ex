defmodule MRP.Organisations.Organisation do
  use MRP, :schema

  schema "parties" do
    field :name, :string, source: :surname

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
