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

  defp assign_filter(socket, filter) do
    inventory = Inventory.list_inventory()

    socket
    |> assign(filter: filter)
    |> stream(:inventory, inventory, reset: true)
  end

  defp assign_sorting_options(socket, options) do
    inventory = Inventory.list_inventory()

    socket
    |> assign(options: options)
    |> stream(:inventory, inventory, reset: true)
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    filter = %{name: ""}
    options = %{
      sort_order: :asc,
      sort_by: :name
    }

    socket =
      if connected?(socket) do
        Endpoint.subscribe(@topic)
        inventory = Inventory.list_inventory()

        socket
        |> stream(:inventory, inventory, reset: true)
      else
        stream(socket, :inventory, [])
      end

      {:ok,
        socket
        |> assign(:page_title, "Inventory")
        |> assign(:options, options)
        |> assign(:filter, filter)}
  end

  @impl Phoenix.LiveView
  def handle_params(params, uri, socket) do
    {:noreply,
      socket
      |> assign_tabs()
      |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"item_id" => id}) do
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
  def handle_event("filter", params, socket) do
    filter = %{name: params["name"]}
    {:noreply, assign_filter(socket, filter)}
  end


  def handle_event("sort", %{"order" => sort_order, "by" => sort_by}, socket) do
    options = %{
      sort_order: String.to_existing_atom(sort_order),
      sort_by: String.to_existing_atom(sort_by)
    }

    {:noreply, assign_sorting_options(socket, options)}
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
        <div class="inline-flex">
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
              <.menu_link phx-click="filter" phx-value-name=""><.icon name="hero-magnifying-glass-solid" class="w-4 h-4 mr-3" />Name</.menu_link>
              <.menu_link phx-click="filter" phx-value-sku=""><.icon name="hero-chart-bar-solid" class="w-4 h-4 mr-3" />SKU</.menu_link>
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

    <div class="mb-4 overflow-x-auto overflow-y-hidden">
      <.table id="all-inventory-table" rows={@streams.inventory} loading={not connected?(@socket)} class="text-sm text-zinc-300" row_class="grid grid-cols-1 sm:table-row p-4">
        <:col class="w-48 col-span-2" :let={{_id, item}} label={sortable_link("Name", :name, @options)}>
          <%= item.name %>
          <p class="text-xs text-zinc-500"><%= item.category || "Placeholder" %></p>
        </:col>
        <:col data_label="Price per unit" class="w-full sm:w-36 col-start-1" align={:right} :let={{_id, item}} label={sortable_link("Price per unit", :unit_price, @options)}>£<%= item.unit_price %></:col>
        <:col data_label="In stock" class="w-full sm:w-36 col-start-1" align={:right} :let={{_id, item}} label={sortable_link("In stock", :quantity_in_stock, @options)}><%= item.quantity_in_stock %><%= item.unit_of_measurement %></:col>
        <:col data_label="Committed" class="w-full sm:w-36 col-start-1" align={:right} :let={{_id, item}} label={sortable_link("Commited", :committed_stock, @options)}><%= item.committed_stock %><%= item.unit_of_measurement %></:col>
        <:col data_label="Reorder point" class="w-full sm:w-36 col-start-1" align={:right} :let={{_id, item}} label="Reorder point"><%= item.reorder_point %><%= item.unit_of_measurement %></:col>
        <:col class="border-t border-zinc-500 sm:border-none mt-1 pt-1 w-full sm:w-24 col-start-1" align={:right} :let={{_id, item}} label="Diff">
          <%= if diff = Decimal.round(Inventory.calculate_stock_difference(item)) do %>
            <%= if Decimal.negative?(diff) do %>
              <p class="font-semibold text-red-600"><%= diff %><%= item.unit_of_measurement %></p>
            <% else %>
              <p class="font-semibold"><%= diff %><%= item.unit_of_measurement %></p>
            <% end %>
          <% end %>
        </:col>
      </.table>
    </div>
    """
  end

  defp sortable_link(label, col, options) do
    assigns = %{
      label: label,
      col: col,
      sort_order: get_opposite(options.sort_order),
      sort_by: options.sort_by
    }

    ~H"""
    <a phx-click="sort" phx-value-order={@sort_order} phx-value-by={@col} class="inline-flex cursor-pointer group">
        <%= @label %>
      <span class="flex-none px-1 ml-2 text-gray-300 bg-gray-700 rounded group-hover:bg-gray-600">
        <.indicator col={@col} sort_order={@sort_order} sort_by={@sort_by} />
      </span>
    </a>
    """
  end

  defp indicator(%{col: col, sort_by: sort_by, sort_order: :asc} = assigns) when col == sort_by do
    ~H"""
    <.icon name="hero-chevron-up-solid" class="w-4 h-4" />
    """
  end

  defp indicator(%{col: col, sort_by: sort_by, sort_order: :desc} = assigns) when col == sort_by do
    ~H"""
    <.icon name="hero-chevron-down-solid" class="w-4 h-4" />
    """
  end

  defp indicator(assigns) do
    ~H"""
    <.icon name="hero-chevron-up-down-solid" class="w-4 h-4" />
    """
  end

  defp get_opposite(:asc), do: :desc
  defp get_opposite(:desc), do: :asc
end
