defmodule Web.ManagementPages.DashboardLive do
  use Web, :live_view

  alias Web.Components.Layouts

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Dashboard"), layout: {Layouts, :control}}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""

    """
  end
end
