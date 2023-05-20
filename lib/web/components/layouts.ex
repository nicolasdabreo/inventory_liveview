defmodule Web.Layouts do
  @moduledoc false

  use Web, :html

  embed_templates "layouts/*"
end
