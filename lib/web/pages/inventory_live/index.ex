defmodule Web.Pages.InventoryLive.Index do
  use Web, :live_view

  alias Core.Inventory
  alias Web.Endpoint
  alias Web.Presence

  @topic "inventory_live"

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    Endpoint.subscribe(@topic)
    inventory = Inventory.list_inventory()
    {:ok, assign(socket, :page_title, "Inventory") |> stream(:inventory, inventory)}
  end

  @impl Phoenix.LiveView
  def handle_params(params, uri, socket) do
    {:noreply,
      socket
      |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"item_id" => id}) do
    # cond do
    #   user = Presence.is_entity_used(@topic, id) ->
    #     error_message = "is already being edited"

    #     socket
    #     |> put_flash(:error, error_message)
    #     |> push_patch(to: ~p"/inventory/all")

    #   true ->
    #     item = Inventory.get_item!(id)
    #     # Track when opening the entity
    #     Presence.track_live_entity(self(), @topic, socket.assigns.current_user, item)

    #     socket
    #     |> assign(:item, item)
    #   end
      item = Inventory.get_item!(id)

      socket
      |> assign(:item, item)
  end

  defp apply_action(socket, action, _params) when action in [:all, :materials, :products] do
    # Untrack when back on the list
    Presence.untrack(self(), @topic, socket.assigns.current_user.id)

    socket
    |> assign(:item, nil)
  end

  @impl Phoenix.LiveView
  def handle_info(%{event: "presence_diff"} = _diff, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <span class="inline-flex justify-between w-full p-3 border-b shadow-sm isolate border-zinc-600">
      <div class="inline-flex">
        <div class="hidden sm:inline-flex">
          <.link
            patch={~p"/inventory/all"}
            class={[
              "relative inline-flex items-center px-4 py-1 text-xs text-zinc-300 rounded-l-md hover:text-zinc-100",
              (@live_action == :all && "bg-zinc-700") || "bg-zinc-800"
            ]}
          >
            All
          </.link>
          <.link
            patch={~p"/inventory/materials"}
            class={[
              "relative inline-flex items-center px-4 py-1 -ml-px text-xs border-l border-zinc-600 text-zinc-300 hover:text-zinc-100",
              (@live_action == :materials && "bg-zinc-700") || "bg-zinc-800"
            ]}
          >
            Materials
          </.link>
          <.link
            patch={~p"/inventory/products"}
            class={[
              "relative inline-flex items-center px-4 py-1 -ml-px text-xs border-l border-zinc-600 text-zinc-300 rounded-r-md hover:text-zinc-100",
              (@live_action == :products && "bg-zinc-700") || "bg-zinc-800"
            ]}
          >
            Products
          </.link>
        </div>
        <button
          type="button"
          class="relative inline-flex items-center px-4 py-1 text-xs border border-dashed rounded sm:ml-4 text-zinc-300 hover:text-zinc-100 border-zinc-500 hover:border-zinc-400"
        >
          <.icon name="hero-funnel-solid" class="flex-shrink-0 w-3 h-3 mr-2 text-white" /> Filter
        </button>
      </div>

      <div class="relative">
        <.menu id="new-stock-menu">
          <:button :let={{toggle_menu, button_id}}>
            <.button
              id={button_id}
              phx-click={toggle_menu.()}
              icon
              color={nil}
              size={nil}
              class="px-1 py-1"
            >
              <span class="sr-only">Add stock</span>
              <.icon name="hero-plus-solid" />
              <.icon name="hero-chevron-down-solid" class="w-3 h-3 mx-1" />
            </.button>
          </:button>
          <:item>
            <.menu_link phx-click={
              JS.patch(~p"/inventory/new/product") |> toggle_menu("new-stock-menu")
            }>
              <.icon name="hero-tag-solid" class="flex-shrink-0 w-4 h-4 mr-2" />New product
            </.menu_link>
          </:item>
          <:item>
            <.menu_link phx-click={
              JS.patch(~p"/inventory/new/material") |> toggle_menu("new-stock-menu")
            }>
              <.icon name="hero-archive-box-solid" class="flex-shrink-0 w-4 h-4 mr-2" />New material
            </.menu_link>
          </:item>
        </.menu>
      </div>
    </span>

    <.live_component
      module={Web.Pages.InventoryLive.EditComponent}
      id="edit-form-live-component"
      live_action={@live_action}
      item={@item}
    />

    <.table id="all-inventory-table" rows={@streams.inventory} class="my-4 text-sm text-zinc-300">
      <:col :let={{_id, item}} label="Name"><%= item.name %></:col>
      <:col :let={{_id, item}} label="Price per unit"><%= item.unit_price %></:col>
      <:col :let={{_id, item}} label="# In stock"><%= item.quantity_in_stock %></:col>
      <:action :let={{_id, item}}>
        <%= case item.actions.edit do %>
          <% {:locked, reason} -> %>
            <.link class="text-gray-300 hover:cursor-not-allowed" title={reason}>Edit</.link>
          <% true -> %>
            <.link patch={~p"/inventory/#{item}/edit"}>Edit</.link>
        <% end %>
      </:action>
      <:action :let={{_id, item}}>
        <%= case item.actions.delete do %>
          <% {:locked, reason} -> %>
            <.link class="text-gray-300 hover:cursor-not-allowed" title={reason}>Delete</.link>
          <% true -> %>
            <.link
              phx-click={JS.push("delete", value: %{id: item.id})}
              data-confirm="Are you sure?"
            >
              Delete
            </.link>
        <% end %>
      </:action>
    </.table>
    """
  end
end
