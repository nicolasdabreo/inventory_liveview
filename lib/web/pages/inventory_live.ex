defmodule Web.Pages.InventoryLive do
  use Web, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Inventory")}
  end

  @impl Phoenix.LiveView
  def handle_params(params, uri, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <span class="inline-flex justify-between w-full p-3 border-b shadow-sm isolate border-zinc-600">
      <div class="inline-flex">
        <.link patch={~p"/inventory/all"} class={["relative inline-flex items-center px-4 py-1 text-xs text-zinc-300 bg-zinc-800 rounded-l-md hover:text-zinc-100", @live_action == :all && "bg-zinc-700"]}>All</.link>
        <.link patch={~p"/inventory/materials"} class={["relative inline-flex items-center px-4 py-1 -ml-px text-xs border-l border-zinc-600 text-zinc-300 bg-zinc-800 hover:text-zinc-100", @live_action == :materials && "bg-zinc-700"]}>Materials</.link>
        <.link patch={~p"/inventory/products"} class={["relative inline-flex items-center px-4 py-1 -ml-px text-xs border-l border-zinc-600 text-zinc-300 bg-zinc-800 rounded-r-md hover:text-zinc-100", @live_action == :products && "bg-zinc-700"]}>Products</.link>
        <button type="button" class="relative inline-flex items-center px-4 py-1 ml-6 text-xs border border-dashed rounded text-zinc-300 hover:text-zinc-100 border-zinc-500 hover:border-zinc-400"><.icon name="hero-funnel-solid" class="flex-shrink-0 w-3 h-3 mr-2 text-white" /> Filter</button>
      </div>

      <div class="relative">
        <.menu id="new-stock-menu">
          <:button :let={{toggle_menu, button_id}}>
            <.button id={button_id} phx-click={toggle_menu.()} icon color={nil} size={nil} class="px-1 py-1">
              <span class="sr-only">Add stock</span>
              <.icon name="hero-plus-solid" />
              <.icon name="hero-chevron-down-solid" class="w-3 h-3 mx-1" />
            </.button>
          </:button>
          <:item>
            <.menu_link><.icon name="hero-tag-solid" class="flex-shrink-0 w-4 h-4 mr-2" />New product</.menu_link>
          </:item>
          <:item>
            <.menu_link><.icon name="hero-archive-box-solid" class="flex-shrink-0 w-4 h-4 mr-2" />New material</.menu_link>
          </:item>
        </.menu>
      </div>

    </span>
    """
  end
end
