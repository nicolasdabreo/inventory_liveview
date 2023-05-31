defmodule Web.Pages.AuthenticationLive.Organisations do
  use Web, :live_view

  def render(assigns) do
    ~H"""
    <.container>
      <.header class="text-center">
        Choose an organisation
      </.header>

      <ul role="list" class="grid grid-cols-1 mt-10 gap-y-8">
        <li class="overflow-hidden border border-gray-200 rounded-md">
          <div class="flex items-center p-6 border-b gap-x-4 border-gray-900/5 bg-gray-50">
            <img src="https://tailwindui.com/img/logos/48x48/tuple.svg" alt="Tuple" class="flex-none object-cover w-12 h-12 bg-white rounded-lg ring-1 ring-gray-900/10">
            <div class="text-sm font-medium leading-6 text-gray-900">Tuple</div>
            <div class="relative ml-auto">
              <button type="button" class="-m-2.5 block p-2.5 text-gray-400 hover:text-gray-500" id="options-menu-0-button" aria-expanded="false" aria-haspopup="true">
                <span class="sr-only">Open options</span>
                <svg class="w-5 h-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                  <path d="M3 10a1.5 1.5 0 113 0 1.5 1.5 0 01-3 0zM8.5 10a1.5 1.5 0 113 0 1.5 1.5 0 01-3 0zM15.5 8.5a1.5 1.5 0 100 3 1.5 1.5 0 000-3z" />
                </svg>
              </button>
            </div>
          </div>
          <a href="http://tuple.mrp.com:4000" class="flex flex-row justify-between px-6 py-4 text-sm leading-6">
            Foo
            <.icon name="hero-arrow-right-solid" class="w-5 h-5" />
          </a>
        </li>
      </ul>
    </.container>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Your Organisations")}
  end

  def handle_params(_uri, params, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, _any, _params) do
    socket
  end
end
