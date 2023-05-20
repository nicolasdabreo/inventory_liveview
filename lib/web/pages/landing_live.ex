defmodule Web.Pages.LandingLive do
  @moduledoc false

  use Web, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Welcome to MRP!")}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.header>Landing page</.header>
    """
  end
end
