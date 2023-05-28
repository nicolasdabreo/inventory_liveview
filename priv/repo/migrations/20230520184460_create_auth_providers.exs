defmodule MRP.Repo.Migrations.CreateAuthProviders do
  use Ecto.Migration

  def change do
    create table(:authentication_providers) do
      add :name, :string, null: false
      timestamps()
    end

    create unique_index(:authentication_providers, [:name])
  end
end
