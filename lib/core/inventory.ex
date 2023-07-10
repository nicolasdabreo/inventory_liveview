defmodule Core.Inventory do
  use MRP, :domain

  alias __MODULE__, as: Inventory
  # alias __MODULE__.Events

  ## Changesets

  def change_inventory_item(inventory_or_changeset \\ %Inventory.Item{}, attrs) do
    Inventory.Item.changeset(inventory_or_changeset, attrs)
  end

  ## Events

  def create_inventory_item(attrs) do
    %Inventory.Item{}
    |> Inventory.Item.create_changeset(attrs)
    |> Repo.insert()

    # broadcast(organisation_id, %Events.InventoryItemCreated{list: []})
  end

  ## Reads

  def get_item!(id), do: Repo.get!(Inventory.Item, id)

  def calculate_stock_difference(%Inventory.Item{
        quantity_in_stock: quantity_in_stock,
        committed_stock: committed_stock,
        reorder_point: reorder_point
      }) do
    remaining_stock = Decimal.sub(quantity_in_stock, committed_stock)
    difference = Decimal.sub(remaining_stock, reorder_point)
    difference
  end

  def list_inventory(_options \\ [])

  def list_inventory(options) do
    Inventory.Item
    |> filter_by_name(options[:filter])
    |> sort(options[:sort])
    |> Repo.all()
  end

  defp sort(query, %{sort_by: sort_by, sort_order: sort_order}) do
    order_by(query, {^sort_order, ^sort_by})
  end

  defp sort(query, _options), do: query

  defp filter_by_name(query, %{name: ""}), do: query

  defp filter_by_name(query, %{name: name}) do
    ilike = "%#{name}%"
    where(query, [c], ilike(c.name, ^ilike))
  end

  ## PubSub

  # @doc """
  # Subscribes the current process to the organisation's inventory PubSub.
  # """
  # def subscribe(organisation_id) do
  #   Phoenix.PubSub.subscribe(MRP.PubSub, topic(organisation_id))
  # end

  # defp broadcast(organisation_id, event) do
  #   Phoenix.PubSub.broadcast(MRP.PubSub, topic(organisation_id), {__MODULE__, event})
  # end

  # defp topic(organisation_id), do: "inventory:#{organisation_id}"
end
