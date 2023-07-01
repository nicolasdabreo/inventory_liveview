defmodule Core.Inventory.Events do
  @moduledoc """
  Defines Event structs for use within the pubsub system.
  """

  defmodule InventoryItemCreated do
    defstruct list: nil, log: nil
  end

  defmodule InventoryItemUpdated do
    defstruct list: nil, log: nil
  end

  defmodule InventoryItemRepositioned do
    defstruct todo: nil, log: nil
  end

  defmodule InventoryItemDeleted do
    defstruct todo: nil, log: nil
  end
end
