defmodule Web.Pages.InventoryLive.New do
  use Web, :live_view

  alias Core.Inventory

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    changeset = Inventory.change_inventory_item(%{})
    {:ok, assign(socket, :page_title, "New inventory") |> assign_form(changeset)}
  end

  @impl Phoenix.LiveView
  def handle_params(params, uri, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.container class="max-w-3xl py-8 sm:py-12">
      <.header class="pb-4 mb-4 border-b text-zinc-200 border-zinc-700">
        Create a new inventory item
        <:subtitle>
          Inventory items represent a collection of stock. You can provide many variants of the same collection to connect different providers and unit price points.
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="new-inventory-item-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Item name" required />
        <.input field={@form[:unit_price]} type="number" label="Unit price" required />
        <.input field={@form[:unit_of_measurement]} type="text" label="Unit of measurement" required placeholder="kg" />
        <.input field={@form[:reorder_point]} type="number" label="Reorder point" required />
        <.input field={@form[:quantity_in_stock]} type="number" label="Quantity in stock" required />

        <div class="flex justify-end">
          <.button type="submit" phx-disable-with="Creating...">Create inventory</.button>
        </div>
      </.simple_form>
    </.container>
    """
  end

  def handle_event("validate", %{"inventory_item" => params}, socket) do
    changeset = Inventory.change_inventory_item(params)
    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"inventory_item" => params}, socket) do
    {:ok, inventory} = Inventory.create_inventory_item(params)

    {:noreply,
     socket
     |> push_redirect(to: ~p"/inventory/all")}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset, as: :inventory_item))
  end
end
