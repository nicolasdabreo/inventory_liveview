defmodule Core.Inventory do
  use MRP, :domain

  alias __MODULE__, as: Inventory
  alias __MODULE__.Events

  ## Changesets

  def change_inventory_item(inventory_or_changeset, attrs) do
    Inventory.Item.changeset(inventory_or_changeset, attrs)
  end

  ## Events

  def create_inventory_item(organisation_id) do
    broadcast(organisation_id, %Events.InventoryItemCreated{list: []})
  end

  ## Reads

  # def list_inventory() do

  # end

  ## PubSub

  @doc """
  Subscribes the current process to the organisation's inventory PubSub.
  """
  def subscribe(organisation_id) do
    Phoenix.PubSub.subscribe(MRP.PubSub, topic(organisation_id))
  end

  defp broadcast(organisation_id, event) do
    Phoenix.PubSub.broadcast(MRP.PubSub, topic(organisation_id), {__MODULE__, event})
  end

  defp topic(organisation_id), do: "inventory:#{organisation_id}"
end
