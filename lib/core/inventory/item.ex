defmodule Core.Inventory.Item do
  use MRP, :schema

  schema "inventory_items" do
    field :name, :string
    field :description, :string
    field :category, :string
    field :supplier_information, :string
    field :unit_price, :decimal
    field :unit_of_measurement, :string
    field :quantity_in_stock, :decimal
    field :committed_stock, :decimal, default: Decimal.new("0.0")
    field :reorder_point, :integer
    field :type, Ecto.Enum, values: [:product, :supply, :material]

    field :actions, :map, virtual: true, default: %{edit: true, delete: true}
    field :toggled, :boolean, default: false, virtual: true

    timestamps()
  end

  def changeset(item, params \\ %{}) do
    item
    |> cast(params, [
      :name,
      :description,
      :category,
      :supplier_information,
      :unit_price,
      :quantity_in_stock,
      :committed_stock,
      :reorder_point
    ])
    |> validate_required([
      :name,
      :unit_price,
      :quantity_in_stock,
      :reorder_point
    ])
    |> validate_number(:unit_price, greater_than: 0)
    |> validate_number(:quantity_in_stock, greater_than_or_equal_to: 0)
    |> validate_number(:reorder_point, greater_than_or_equal_to: 0)
  end

  def create_changeset(item, params \\ %{}) do
    item
    |> cast(params, [
      :name,
      :description,
      :category,
      :supplier_information,
      :unit_price,
      :quantity_in_stock,
      :reorder_point
    ])
    |> validate_required([
      :name,
      :unit_price,
      :quantity_in_stock,
      :reorder_point
    ])
    |> validate_number(:unit_price, greater_than: 0)
    |> validate_number(:quantity_in_stock, greater_than_or_equal_to: 0)
    |> validate_number(:reorder_point, greater_than_or_equal_to: 0)
  end
end
