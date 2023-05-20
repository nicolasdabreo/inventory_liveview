defmodule Web.Pages.ErrorHTML do
  @moduledoc false

  use Web, :html

  embed_templates "error_html/*"
end
