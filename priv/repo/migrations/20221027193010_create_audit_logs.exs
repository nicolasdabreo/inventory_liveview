defmodule Store.Repo.Migrations.CreateAuditLogs do
  use Ecto.Migration

  def change do
    create table(:audit_logs, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:action, :string, null: false)
      add(:ip_address, :inet)
      add(:user_agent, :string)
      add(:user_email, :string)
      add(:params, :map, null: false)
      add(:user_id, references(:users, type: :uuid, column: :id, on_delete: :nilify_all))
      add(:tenant_id, references(:tenants, type: :uuid, column: :id, on_delete: :nilify_all))
      timestamps(updated_at: false)
    end

    create(index(:audit_logs, [:user_id]))
    create(index(:audit_logs, [:tenant_id]))
  end
end
