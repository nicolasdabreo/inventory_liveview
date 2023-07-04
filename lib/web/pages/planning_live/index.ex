defmodule Web.Pages.PlanningLive.Index do
  use Web, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Planning")}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""

    """
  end
end
