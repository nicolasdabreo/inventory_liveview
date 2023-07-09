defmodule Web.Pages.InventoryLive.EditComponent do
  use Web, :live_component

  alias Core.Inventory

  def render(assigns) do
    ~H"""
    <div>
      <.modal
        :if={@live_action in [:edit]}
        show
        id={"#{@live_action}-modal"}
        on_cancel={JS.patch(~p"/inventory/products")}
        on_confirm={JS.exec("phx-submit")}
      >
        <h2 class="mb-2">Edit <%= @item.name %></h2>

        <.simple_form
          for={@form}
          id="new-inventory-item-form"
          phx-change="validate"
          phx-submit="save"
          phx-target={@myself}
        >
          <.input field={@form[:name]} type="text" label="Item name" />
          <.input field={@form[:description]} type="textarea" label="Description" />

          <div class="flex justify-end space-x-4">
            <.button type="submit">Save</.button>
          </div>
        </.simple_form>
      </.modal>
    </div>
    """
  end

  def update(assigns, socket) do
    changeset = Inventory.change_inventory_item(%{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  def handle_event("validate", %{"form" => _params}, socket) do
    changeset = Inventory.change_inventory_item(socket.assigns.item, %{})

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"form" => _params}, socket) do
    {:noreply, socket}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset, as: :inventory_item))
  end
end
