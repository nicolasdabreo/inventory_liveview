defmodule Web.Redirect do
  @moduledoc """
  A Plug to allow for easily doing redirects within a Plug or Phoenix router.

  Based on code found at:
    https://www.viget.com/articles/how-to-redirect-from-the-phoenix-router/
  """

  @behaviour Plug

  @impl Plug
  def init([to: to] = opts) when is_binary(to), do: opts
  def init(_opts), do: raise("Missing required option ':to' in redirect")

  @impl Plug
  def call(conn, opts), do: Phoenix.Controller.redirect(conn, opts)
end
