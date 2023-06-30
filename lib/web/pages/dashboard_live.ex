defmodule Web.Pages.DashboardLive do
  use Web, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Dashboard")}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    Dashboard
    """
  end
end
