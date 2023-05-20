defmodule Web.Pages.Home do
  @moduledoc false

  use Web, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "List products")
     |> assign(:products, [])}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>Kitchen sink</.header>
    <div class="grid mt-10 auto-cols-max gap-x-6 gap-y-4">
      <a
        href={~p"/listings"}
        class="relative px-6 py-4 text-sm font-semibold leading-6 group rounded-2xl text-zinc-900"
      >
        <span class="absolute inset-0 transition rounded-2xl bg-zinc-50 group-hover:bg-zinc-100 sm:group-hover:scale-105">
        </span>
        <span class="relative flex items-center gap-4">
          <Heroicons.list_bullet class="w-5 h-5" /> My Listings
        </span>
      </a>
    </div>
    """
  end
end
