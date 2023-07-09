defmodule Web.Components.Layouts do
  @moduledoc false

  use Web, :html

  embed_templates "layouts/*"

  @locale_data [
    %{language: "English", locale: "en", flag: "🏴󠁧󠁢󠁥󠁮󠁧󠁿"},
    %{language: "Polish", locale: "pl", flag: "🇵🇱"}
  ]

  def locale_options do
    Enum.map(@locale_data, &{"#{&1.flag} #{&1.language}", &1.locale})
  end

  def locale_select(assigns) do
    ~H"""
    <div class="relative">
      <.menu id="locale-select" class="w-32">
        <:trigger :let={{toggle_menu, button_id}}>
          <button
            id={button_id}
            phx-click={toggle_menu.()}
            type="button"
            class="focus:border-violet-500 focus:ring-2 focus:outline-none focus:ring-violet-200 relative w-full cursor-default rounded-md bg-white py-1.5 pl-3 pr-10 text-left text-gray-900 shadow-sm border sm:text-sm sm:leading-6"
          >
            <span class="block truncate"><%= @current_locale %></span>
            <span class="absolute inset-y-0 right-0 flex items-center pr-2 pointer-events-none">
              <.icon name="hero-chevron-up-down-solid" class="text-gray-400" />
            </span>
          </button>
        </:trigger>
        <:item :for={{label, value} <- locale_options()}>
          <.menu_link phx-click="change_locale" phx-value-locale={value}><%= label %></.menu_link>
        </:item>
      </.menu>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  def flash_group(assigns) do
    ~H"""
    <div class="fixed z-50 flex flex-col gap-3 bottom-5 left-5 w-80 sm:w-96">
      <.flash kind={:info} title="Success!" flash={@flash} />
      <.flash kind={:error} title="Error!" flash={@flash} />
      <.flash
        id="disconnected"
        kind={:error}
        phx-disconnected={show("#disconnected")}
        phx-connected={hide("#disconnected")}
        hidden
      >
        Attempting to reconnect <.icon name="hero-arrow-path" class="w-3 h-3 ml-1 animate-spin" />
      </.flash>
    </div>
    """
  end
end
