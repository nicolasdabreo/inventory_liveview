defmodule Web.Pages.LandingLive do
  @moduledoc false

  use Web, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Welcome to MRP!")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>Landing page</.header>
    """
  end
end
