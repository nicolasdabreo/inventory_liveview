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

  defp assign_inventory(socket) do
    inventory =
      Inventory.list_inventory(socket.assigns.inventory_type,
        filter: socket.assigns.filter,
        sort: socket.assigns.sort
      )
    |> Enum.map(& if &1.id in socket.assigns.selected_rows, do: %{&1 | toggled: true}, else: &1)

    stream(socket, :inventory, inventory, reset: true)
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    filter = %{name: "", category: ""}

    sort = %{
      sort_order: :asc,
      sort_by: :name
    }

    if connected?(socket) do
      Endpoint.subscribe(@topic)
    end

    total = Inventory.total_inventory_count()

    {:ok,
     socket
     |> assign(:page_title, "Inventory")
     |> assign(:selected_rows, [])
     |> assign(:selected_row_count, 0)
     |> assign(:total_inventory_count, total)
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
    type = type_by_action(action)

    socket
    |> assign(:item, nil)
    |> assign(:inventory_type, type)
    |> assign_inventory()
  end

  defp type_by_action(:supplies), do: :supply
  defp type_by_action(:products), do: :product
  defp type_by_action(:materials), do: :material

  @impl Phoenix.LiveView
  def handle_event("filter", params, socket) do
    filter =
      for {k, v} <- %{name: params["name"], category: params["category"]},
          !is_nil(v),
          into: %{},
          do: {k, v}

    filter = Map.merge(socket.assigns.filter, filter)

    {:noreply,
      socket
      |> assign(filter: filter)
      |> assign_inventory()}
  end

  def handle_event("sort", %{"order" => sort_order, "by" => sort_by}, socket) do
    sort = %{
      sort_order: String.to_existing_atom(sort_order),
      sort_by: String.to_existing_atom(sort_by)
    }

    {:noreply,
      socket
      |> assign(sort: sort)
      |> assign_inventory()}
  end

  def handle_event("select-row", %{"id" => row_id}, socket) do
    item = Inventory.get_item!(row_id)

    selected_rows = socket.assigns.selected_rows ++ [item.id]

    {:noreply,
     socket
     |> assign(:selected_rows, selected_rows)
     |> stream_delete(:inventory, item)
     |> stream_insert(:inventory, %{item | toggled: true})
     |> assign(:selected_row_count, Enum.count(selected_rows))}
  end

  def handle_event("deselect-row", %{"id" => row_id}, socket) do
    item = Inventory.get_item!(row_id)

    selected_rows = Enum.reject(socket.assigns.selected_rows, & &1 == item.id)

    {:noreply,
      socket
      |> assign(:selected_rows, selected_rows)
      |> stream_delete(:inventory, item)
      |> stream_insert(:inventory, %{item | toggled: false})
      |> assign(:selected_row_count, Enum.count(selected_rows))}
  end

  @impl Phoenix.LiveView
  def handle_info(%{event: "presence_diff"} = _diff, socket) do
    {:noreply, socket}
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
