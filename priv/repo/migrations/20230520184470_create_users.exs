defmodule MRP.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :party_id, references(:parties, type: :uuid, on_delete: :delete_all)
      timestamps()
    end

    create index(:users, [:party_id])

    create table(:emails, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :email, :citext, null: false
      add :verified_at, :naive_datetime
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all)
      timestamps()
    end

    create index(:emails, [:id])
    create unique_index(:emails, [:email])

    create table(:credentials, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :type, :string
      add :value, :string
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all)
      timestamps()
    end

    create index(:credentials, [:id])

    create table(:users_tokens, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])
  end
end
