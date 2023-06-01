defmodule Web.Cldr do
  @moduledoc """
  I18n for numbers, currencies, dates and calendar.
  """

  use Cldr,
    gettext: Web.Gettext,
    locales: Gettext.known_locales(Web.Gettext),
    default_locale: "en",
    otp_app: :mrp,
    providers: [Cldr.Number, Money, Cldr.DateTime, Cldr.Calendar],
    locales: ["pl", "en"],
    data_dir: "./priv/cldr"
end
