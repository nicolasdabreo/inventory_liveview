defmodule Web.Assigns do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """

  use Web, :verified_routes

  import Phoenix.LiveView
  import Phoenix.Component

  def on_mount(:default, _params, _session, socket) do
    {:cont,
     socket
     |> assign_uri_info()}
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
