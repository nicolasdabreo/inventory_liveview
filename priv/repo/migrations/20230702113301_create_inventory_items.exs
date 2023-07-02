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
      add :quantity_in_stock, :integer, null: false
      add :reorder_point, :integer, null: false

      timestamps()
    end
  end
end
