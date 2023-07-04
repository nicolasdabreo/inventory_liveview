defmodule Web.Pages.InventoryLive.Index do
  use Web, :live_view

  alias Core.Inventory
  alias Web.Endpoint
  alias Web.Presence

  @topic "inventory_live"

  defp assign_tabs(socket) do
    assign(socket, :tabs, [
      %{navigate: "/sales", text: "Sales", selected: socket.assigns.active_path =~ "/sales"},
      %{navigate: "/planning", text: "Planning", selected: socket.assigns.active_path =~ "/planning"},
      %{navigate: "/inventory/all", text: "Inventory", selected: socket.assigns.active_path =~ "/inventory"}
    ])
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    Endpoint.subscribe(@topic)
    inventory = Inventory.list_inventory()

    {:ok,
      assign(socket, :page_title, "Inventory")
      |> stream(:inventory, inventory)}
    end

    @impl Phoenix.LiveView
    def handle_params(params, uri, socket) do
    {:noreply,
      socket
      |> apply_action(socket.assigns.live_action, params)
      |> assign_tabs()
    }
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
    <span class="inline-flex justify-between w-full p-3 border-b shadow-sm border-zinc-600">
      <div class="inline-flex sm:space-x-4">
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

        <div class="relative w-48">
          <.menu id="filter-inventory-menu" placement="right">
            <:trigger :let={{toggle_menu, button_id}}>
              <button
                id={button_id}
                phx-click={toggle_menu.()}
                type="button"
                aria-haspopup="true"
                class="relative inline-flex items-center h-full px-4 py-1 text-xs border border-dashed rounded text-zinc-300 hover:text-zinc-100 border-zinc-500 hover:border-zinc-400"
              >
                <.icon name="hero-funnel-solid" class="flex-shrink-0 w-3 h-3 mr-2 text-white" /> Filter
              </button>
            </:trigger>
            <:item>

            </:item>
            <:item><.divider /></:item>
            <:item>
              <.menu_link><.icon name="hero-magnifying-glass-solid" class="w-4 h-4 mr-3" />Name</.menu_link>
              <.menu_link><.icon name="hero-chart-bar-solid" class="w-4 h-4 mr-3" />SKU</.menu_link>
              <.menu_link><.icon name="hero-folder-solid" class="w-4 h-4 mr-3" />Category</.menu_link>
              <.menu_link><.icon name="hero-building-office-solid" class="w-4 h-4 mr-3" />Supplier</.menu_link>
            </:item>
            <:item><.divider /></:item>
            <:item>
              <.menu_link><.icon name="hero-currency-dollar-solid" class="w-4 h-4 mr-3" />Price</.menu_link>
              <.menu_link><.icon name="hero-square-3-stack-3d-solid" class="w-4 h-4 mr-3" />Quantity</.menu_link>
              <.menu_link><.icon name="hero-calendar-solid" class="w-4 h-4 mr-3" />Created date</.menu_link>
              <.menu_link><.icon name="hero-wrench-screwdriver-solid" class="w-4 h-4 mr-3" />Components</.menu_link>
            </:item>
          </.menu>
        </div>
      </div>

      <div class="relative">
        <.menu id="new-stock-menu" placement="left">
          <:trigger :let={{toggle_menu, button_id}}>
            <.button
              id={button_id}
              phx-click={toggle_menu.()}
              icon
              color={nil}
              size={nil}
              class="px-1 py-1"
              aria-haspopup="true"
            >
              <span class="sr-only">Add stock</span>
              <.icon name="hero-plus-solid" />
              <.icon name="hero-chevron-down-solid" class="w-3 h-3 mx-1" />
            </.button>
          </:trigger>
          <:item>
            <.menu_link navigate={~p"/inventory/new/product"}>
              <.icon name="hero-tag-solid" class="flex-shrink-0 w-4 h-4 mr-2" />New product
            </.menu_link>
          </:item>
          <:item>
            <.menu_link navigate={~p"/inventory/new/material"}>
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

    <div class="mb-4 overflow-y-auto sm:overflow-visible">
      <.table id="all-inventory-table" rows={@streams.inventory} class="text-sm text-zinc-300">
        <:col sort :let={{_id, item}} label="Name"><%= item.name %></:col>
        <:col sort :let={{_id, item}} label="Price per unit"><%= item.unit_price %></:col>
        <:col sort :let={{_id, item}} label="# In stock"><%= item.quantity_in_stock %><%= item.unit_of_measurement %></:col>
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
              <.link phx-click={JS.push("delete", value: %{id: item.id})} data-confirm="Are you sure?">
                Delete
              </.link>
          <% end %>
        </:action>
      </.table>
    </div>
    """
  end
end
