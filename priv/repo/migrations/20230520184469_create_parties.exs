defmodule MRP.Repo.Migrations.CreateParties do
  use Ecto.Migration

  def change do
    create table(:parties, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :type, :string, null: false
      timestamps()
    end

    create index(:parties, [:id])
  end
end
