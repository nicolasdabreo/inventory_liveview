defmodule Web.Assigns do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """

  use Web, :verified_routes

  import Phoenix.LiveView
  import Phoenix.Component

  alias Store.Listings
  alias Web.RequestContext

  def on_mount(:default, _params, _session, socket) do
    {:cont,
     socket
     |> RequestContext.put_audit_context()
     |> assign_uri_info()}
  end

  def on_mount(:selling, _params, _session, socket) do
    {:cont,
     socket
     |> assign_new(:seller, fn ->
       Listings.Sellers.get_seller!(socket.assigns.current_user.id)
     end)}
  end

  def on_mount(:buying, _params, _session, socket) do
    {:cont, socket}
  end

  defp assign_uri_info(socket) do
    attach_hook(socket, :uri_info, :handle_params, fn
      params, uri, socket ->
        socket =
          socket
          |> assign(:active_path, URI.parse(uri).path)
          |> assign(:params, params)

        {:cont, socket}
    end)
  end
end
