defmodule Web.Pages.InventoryLive.Index do
  use Web, :live_view

  alias Core.Inventory
  alias Web.Endpoint
  alias Web.Presence

  @topic "inventory_live"

  defp assign_tabs(socket) do
    assign(socket, :tabs, [
      %{navigate: "/sales", text: "Sales", selected: socket.assigns.active_path =~ "/sales"},
      %{
        navigate: "/planning",
        text: "Planning",
        selected: socket.assigns.active_path =~ "/planning"
      },
      %{
        navigate: "/inventory/products",
        text: "Inventory",
        selected: socket.assigns.active_path =~ "/inventory"
      }
    ])
  end

  defp assign_filter(socket, filter) do
    inventory = Inventory.list_inventory(filter: filter, sort: socket.assigns.sort)

    socket
    |> assign(filter: filter)
    |> stream(:inventory, inventory, reset: true)
  end

  defp assign_sort(socket, sort) do
    inventory = Inventory.list_inventory(sort: sort, filter: socket.assigns.filter)

    socket
    |> assign(sort: sort)
    |> stream(:inventory, inventory, reset: true)
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    filter = %{name: ""}

    sort = %{
      sort_order: :asc,
      sort_by: :name
    }

    socket =
      if connected?(socket) do
        Endpoint.subscribe(@topic)
        inventory = Inventory.list_inventory(sort: sort, filter: filter)

        socket
        |> stream(:inventory, inventory, reset: true)
      else
        stream(socket, :inventory, [])
      end

    {:ok,
     socket
     |> assign(:page_title, "Inventory")
     |> assign(:sort, sort)
     |> assign(:filter, filter)}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _uri, socket) do
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

  defp apply_action(socket, action, _params) when action in [:supplies, :materials, :products] do
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
    sort = %{
      sort_order: String.to_existing_atom(sort_order),
      sort_by: String.to_existing_atom(sort_by)
    }

    {:noreply, assign_sort(socket, sort)}
  end

  @impl Phoenix.LiveView
  def handle_info(%{event: "presence_diff"} = _diff, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <span class="sticky top-0 z-20 inline-flex justify-between w-full p-3 border-b shadow-sm border-zinc-600 bg-zinc-900">
      <div class="inline-flex sm:space-x-4">
        <div class="hidden sm:inline-flex">
          <.link
            patch={~p"/inventory/products"}
            class={[
              "relative inline-flex items-center px-4 py-1 -ml-px text-sm rounded-l-md text-zinc-300 hover:text-zinc-100",
              (@live_action == :products && "bg-zinc-700") || "bg-zinc-800"
            ]}
          >
            Products
          </.link>
          <.link
            patch={~p"/inventory/materials"}
            class={[
              "relative inline-flex items-center px-4 py-1 -ml-px text-sm border-l border-zinc-600 text-zinc-300 hover:text-zinc-100",
              (@live_action == :materials && "bg-zinc-700") || "bg-zinc-800"
            ]}
          >
            Materials
          </.link>
          <.link
            patch={~p"/inventory/supplies"}
            class={[
              "rounded-r-md relative inline-flex items-center px-4 py-1 text-sm border-l border-zinc-600 text-zinc-300 hover:text-zinc-100",
              (@live_action == :supplies && "bg-zinc-700") || "bg-zinc-800"
            ]}
          >
            Supplies
          </.link>
        </div>
        <div class="relative inline-flex mr-2 sm:hidden">
          <.menu id="inventory-nav-menu" placement="right">
            <:trigger :let={{toggle_menu, button_id}}>
              <button
                id={button_id}
                phx-click={toggle_menu.()}
                type="button"
                aria-haspopup="true"
                class="relative inline-flex items-center h-full px-4 py-1 text-sm border rounded text-zinc-300 bg-zinc-700 border-zinc-500 hover:text-zinc-100 hover:border-zinc-400"
              >
                <%= case @live_action do %>
                  <% :products -> %>
                    Products
                  <% :materials -> %>
                    Materials
                  <% :supplies -> %>
                    Supplies
                <% end %>
                <.icon name="hero-chevron-down-solid" class="w-3 h-3 ml-2" />
              </button>
            </:trigger>
            <:item></:item>
            <:item><.divider /></:item>
            <:item>
              <.menu_link navigate={~p"/inventory/products"}>Products</.menu_link>
              <.menu_link navigate={~p"/inventory/materials"}>Materials</.menu_link>
              <.menu_link navigate={~p"/inventory/supplies"}>Supplies</.menu_link>
            </:item>
          </.menu>
        </div>

        <div class="relative w-32 mr-2">
          <.menu id="filter-inventory-menu" placement="right">
            <:trigger :let={{toggle_menu, button_id}}>
              <button
                id={button_id}
                phx-click={toggle_menu.()}
                type="button"
                aria-haspopup="true"
                class="relative inline-flex items-center h-full px-4 py-1 text-xs border border-dashed rounded text-zinc-300 border-zinc-500 hover:text-zinc-100 hover:border-zinc-400"
              >
                <.icon name="hero-funnel-solid" class="flex-shrink-0 w-3 h-3 mr-2 text-white" />
                Filter
              </button>
            </:trigger>
            <:item>
              <.menu_link phx-click={toggle_menu("sub-menu")} class="justify-between">
                <span class="inline-flex items-center">
                  <.icon name="hero-magnifying-glass-solid" class="w-4 h-4 mr-3" />
                  Name
                </span>
                <.icon name="hero-chevron-right-solid" class="flex-shrink-0 w-4 h-4" />
              </.menu_link>
              <.menu_link phx-click="filter" phx-value-sku="">
                <.icon name="hero-chart-bar-solid" class="w-4 h-4 mr-3" />SKU
              </.menu_link>
              <.menu_link><.icon name="hero-folder-solid" class="w-4 h-4 mr-3" />Category</.menu_link>
              <.menu_link>
                <.icon name="hero-building-office-solid" class="w-4 h-4 mr-3" />Supplier
              </.menu_link>
            </:item>
            <:item><.divider /></:item>
            <:item>
              <.menu_link>
                <.icon name="hero-currency-dollar-solid" class="w-4 h-4 mr-3" />Price
              </.menu_link>
              <.menu_link>
                <.icon name="hero-square-3-stack-3d-solid" class="w-4 h-4 mr-3" />Quantity
              </.menu_link>
              <.menu_link>
                <.icon name="hero-calendar-solid" class="w-4 h-4 mr-3" />Created date
              </.menu_link>
              <.menu_link>
                <.icon name="hero-wrench-screwdriver-solid" class="w-4 h-4 mr-3" />Components
              </.menu_link>
            </:item>
          </.menu>

          <.menu class="left-full" id="sub-menu" placement="right">
            <:item>
              <.menu_link phx-click={toggle_menu("sub-menu") |> JS.push("filter")} phx-value-name="Hat">Hat</.menu_link>
              <.menu_link phx-click={toggle_menu("sub-menu") |> JS.push("filter")} phx-value-name="car">Car</.menu_link>
              <.menu_link phx-click={toggle_menu("sub-menu") |> JS.push("filter")} phx-value-name="Computer">Computer</.menu_link>
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

    <div class="mb-4">
      <.table
        id="all-inventory-table"
        rows={@streams.inventory}
        class="text-zinc-300"
        row_class="grid grid-cols-1 sm:table-row p-4"
        sticky
      >
        <:col
          :let={{_id, item}}
          class="w-48 col-span-2"
          label={sortable_link("Name", :name, @sort)}
        >
          <%= item.name %>
          <p class="text-sm text-zinc-500"><%= item.category || "Placeholder" %></p>
        </:col>
        <:col
          :let={{_id, item}}
          data_label="Price per unit"
          class="w-full col-start-1 sm:w-36"
          align={:right}
          label={sortable_link("Price per unit", :unit_price, @sort)}
        >
        <div class="flex flex-row justify-end gap-2">
          <p class="flex-1 text-right truncate"><%= item.unit_price %></p><p class="w-8 text-left text-zinc-500">GBP</p>
        </div>
        </:col>
        <:col
          :let={{_id, item}}
          data_label="In stock"
          class="w-full col-start-1 sm:w-36"
          align={:right}
          label={sortable_link("In stock", :quantity_in_stock, @sort)}
        >
          <div class="flex flex-row justify-end gap-2">
            <p class="flex-1 text-right truncate"><%= item.quantity_in_stock %></p><p class="w-8 text-left text-zinc-500"><%= item.unit_of_measurement %></p>
          </div>
        </:col>
        <:col
          :let={{_id, item}}
          data_label="Committed"
          class="w-full col-start-1 sm:w-36"
          align={:right}
          label={sortable_link("Commited", :committed_stock, @sort)}
        >
          <div class="flex flex-row justify-end gap-2">
            <p class="flex-1 text-right truncate"><%= item.committed_stock %></p><p class="w-8 text-left text-zinc-500"><%= item.unit_of_measurement %></p>
          </div>
        </:col>
        <:col
          :let={{_id, item}}
          data_label="Reorder point"
          class="w-full col-start-1 sm:w-36"
          align={:right}
          label={sortable_link("Reorder point", :reorder_point, @sort)}
        >
          <div class="flex flex-row justify-end gap-2">
            <p class="flex-1 text-right truncate"><%= item.reorder_point %></p><p class="w-8 text-left text-zinc-500"><%= item.unit_of_measurement %></p>
          </div>
        </:col>
        <:col
          :let={{_id, item}}
          class="w-full col-start-1 pt-1 mt-1 border-t border-zinc-500 sm:border-none sm:w-24"
          align={:right}
          label="Diff"
        >
          <div class="flex flex-row justify-end gap-2">
            <%= if diff = Decimal.round(Inventory.calculate_stock_difference(item)) do %>
              <%= if Decimal.negative?(diff) do %>
                <p class="flex-1 font-semibold text-right text-red-600 truncate"><%= diff %></p><p class="w-8 text-left"><%= item.unit_of_measurement %></p>
              <% else %>
               <p class="flex-1 font-semibold text-right truncate"><%= diff %></p><p class="w-8 text-left text-zinc-500"><%= item.unit_of_measurement %></p>
              <% end %>
            <% end %>
          </div>
        </:col>
      </.table>
    </div>
    """
  end

  defp sortable_link(label, col, sort) do
    assigns = %{
      label: label,
      col: col,
      sort_order: get_opposite(sort.sort_order),
      sort_by: sort.sort_by
    }

    ~H"""
    <a
      phx-click="sort"
      phx-value-order={@sort_order}
      phx-value-by={@col}
      class="inline-flex cursor-pointer group"
    >
      <%= @label %>
      <span class="flex items-center px-1 ml-2 text-zinc-300">
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

  defp indicator(%{col: col, sort_by: sort_by, sort_order: :desc} = assigns)
       when col == sort_by do
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
