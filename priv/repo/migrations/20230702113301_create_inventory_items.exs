defmodule MRP.Repo.Migrations.CreateInventoryItems do
  use Ecto.Migration

  def change do
    create table(:inventory_items, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, null: false
      add :description, :string
      add :category, :string
      add :supplier_information, :string
      add :unit_price, :decimal, null: false
      add :unit_of_measurement, :string
      add :quantity_in_stock, :decimal, null: false
      add :committed_stock, :decimal, null: false
      add :reorder_point, :integer, null: false
      add :type, :string, null: false

      timestamps()
    end
  end
end
