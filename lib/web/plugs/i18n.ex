defmodule Web.Plugs.I18n do
  @cookie "mrp_locale"

  @moduledoc """
  I18n plug to set the language on a HTTP request.

  Looks for the browser cookie `#{@cookie}` first, falling back to the
  AcceptLanguage header and finally falling back to the default locale
  configured by Gettext.
  """

  import Plug.Conn

  @locales Gettext.known_locales(Web.Gettext)

  def init(param), do: param

  def call(%Plug.Conn{req_cookies: %{@cookie => locale}} = conn, _opts)
      when locale in @locales do
    set_locale(conn, locale)
  end

  def call(%Plug.Conn{private: %{cldr_locale: %Cldr.LanguageTag{language: locale}}} = conn, _opts) do
    set_locale(conn, locale)
  end

  def call(conn, _opts), do: conn

  defp set_locale(conn, locale) do
    Gettext.put_locale(Web.Gettext, locale)
    Cldr.put_locale(Web.Cldr, locale)
    put_session(conn, :locale, locale)
  end
end
