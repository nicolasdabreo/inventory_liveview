defmodule Web.Assigns do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """

  use Web, :verified_routes

  import Phoenix.LiveView
  import Phoenix.Component

  def on_mount(:default, _params, %{"locale" => locale} = _session, socket) do
    Gettext.put_locale(Web.Gettext, locale)
    Cldr.put_locale(Web.Cldr, locale)

    {:cont,
     socket
     |> assign_uri_info()
     |> assign(:tabs, [])
     |> assign_locale_info(locale)}
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

  defp assign_locale_info(socket, locale) do
    socket
    |> assign(:current_locale, locale)
    |> attach_hook(:change_locale, :handle_event, fn
      "change_locale", %{"locale" => locale}, socket ->
        locale = locale || socket.assigns.current_locale
        Gettext.put_locale(Web.Gettext, locale)
        Cldr.put_locale(Web.Cldr, locale)

        {:cont,
         socket
         |> assign(:current_locale, locale)
         |> push_event("change-locale", %{locale: locale})}

      _event, _params, socket ->
        {:cont, socket}
    end)
  end
end
