defmodule MRP.Organisations.Owner do
  use MRP, :schema

  schema "parties" do
    field :name, :string
    field :user_id, :string

    belongs_to :tenant, MRP.Organisations.Tenant

    timestamps()
  end
end
