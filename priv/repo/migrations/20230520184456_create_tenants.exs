defmodule MRP.Repo.Migrations.CreateTenants do
  use Ecto.Migration

  def change do
    create table(:tenants, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :subdomain, :string, null: false
      add :brand_color, :string
      add :logo, :string

      timestamps()
    end

    create unique_index(:tenants, [:subdomain])
  end
end
