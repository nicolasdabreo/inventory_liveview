defmodule Web.Components.Core do
  @moduledoc false

  use Phoenix.Component

  alias Phoenix.LiveView.JS

  import Web.Gettext

  @doc """
  Renders a simple form.

  ## Examples

      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} label="Email"/>
        <.input field={@form[:username]} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr :for, :any, required: true, doc: "the datastructure for the form"
  attr :class, :string, default: ""
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr(:rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target),
    doc: "the arbitrary HTML attributes to apply to the form tag"
  )

  slot(:inner_block, required: true)
  slot(:actions, doc: "the slot for form actions, such as a submit button")

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class={["flex flex-col space-y-8", @class]}>
        <%= render_slot(@inner_block, f) %>
        <div :for={action <- @actions} class="flex items-center justify-between gap-6 mt-2">
          <%= render_slot(action, f) %>
        </div>
      </div>
    </.form>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr(:type, :string, default: "button", values: ~w(button submit reset))
  attr(:variant, :string, default: "solid", values: ~w(solid outline))
  attr(:size, :string, default: "md", values: ~w(sm md lg))
  attr(:color, :string, default: "blue")
  attr(:patch, :string, default: nil)
  attr(:navigate, :string, default: nil)
  attr(:href, :string, default: nil)

  attr(:full, :boolean,
    default: false,
    doc: "forces the width to full, tip: add sm:w-max to have it be full only on mobile"
  )

  attr :class, :string, default: nil
  attr :icon, :boolean, default: false
  attr :rest, :global

  slot(:inner_block, required: true)

  def button(%{patch: nil, navigate: nil, href: nil} = assigns) do
    ~H"""
    <button
      class={[
        button_base_classes(@icon),
        button_size_classes(@size),
        button_color_classes(@color),
        @class
      ]}
      type={@type}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  def button(%{patch: _} = assigns), do: ~H"<.link_button {assigns} />"
  def button(%{navigate: _} = assigns), do: ~H"<.link_button {assigns} />"
  def button(%{href: _} = assigns), do: ~H"<.link_button {assigns} />"

  defp link_button(assigns) do
    ~H"""
    <.link
      patch={@patch}
      navigate={@navigate}
      href={@href}
      class={[
        button_base_classes(@icon),
        button_size_classes(@size),
        button_color_classes(@color),
        @class
      ]}
      type={@type}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  defp button_base_classes(false) do
    "inline-flex items-center font-semibold no-underline border border-transparent border border-zinc-300 rounded-md shadow-lg disabled:text-zinc-400 disabled:bg-zinc-200 disabled:hover:bg-zinc-200 disabled:cursor-not-allowed phx-submit-loading:opacity-75 focus-within:outline-none focus-within:ring-2 focus:ring-2 focus:outline-none focus:ring-violet-300"
  end

  defp button_base_classes(true) do
    "inline-flex items-center font-semibold no-underline border border-transparent border border-zinc-300 rounded-md shadow-lg disabled:text-zinc-400 disabled:bg-zinc-200 disabled:hover:bg-zinc-200 disabled:cursor-not-allowed phx-submit-loading:opacity-75 focus-within:outline-none focus-within:ring-2 focus:ring-2 focus:outline-none focus:ring-violet-300"
  end

  defp button_size_classes("sm"), do: "h-8 px-3 py-2 text-sm"
  defp button_size_classes("md"), do: "h-10 px-4 py-2 text-base"
  defp button_size_classes("lg"), do: "h-12 px-6 py-2 text-lg"
  defp button_size_classes(_size), do: ""

  defp button_color_classes("blue"),
    do:
      "bg-blue-600 text-white hover:text-slate-100 hover:bg-blue-500 active:bg-blue-800 active:text-blue-100"

  defp button_color_classes("zinc"),
    do:
      "bg-slate-900 text-white hover:bg-slate-700 hover:text-slate-100 active:bg-slate-800 active:text-slate-300"

  defp button_color_classes("white"),
    do:
      "bg-white text-slate-900 hover:bg-blue-50 active:bg-blue-200 active:text-slate-600 border border-slate-300"

  defp button_color_classes(_size),
    do: "text-zinc-400 hover:text-zinc-300 border border-zinc-400 hover:border-zinc-300"

  @doc """
  Renders a header with title.
  """
  attr(:class, :string, default: nil)

  slot(:inner_block, required: true)
  slot(:subtitle)
  slot(:actions)

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", @class]}>
      <div>
        <h1 class="text-xl font-semibold leading-8 text-zinc-200">
          <%= render_slot(@inner_block) %>
        </h1>
        <p :if={@subtitle != []} class="mt-1 text-sm leading-6 text-zinc-400">
          <%= render_slot(@subtitle) %>
        </p>
      </div>
      <div class="flex-none"><%= render_slot(@actions) %></div>
    </header>
    """
  end

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr(:class, :string, default: nil)
  attr(:navigate, :any, required: true)
  slot(:inner_block, required: true)

  def back(assigns) do
    ~H"""
    <div class="">
      <.link
        navigate={@navigate}
        class={["text-sm font-semibold leading-6 text-white hover:text-zinc-700", @class]}
      >
        <.icon name="hero-arrow-left-solid" class="w-3 h-3" />
        <%= render_slot(@inner_block) %>
      </.link>
    </div>
    """
  end

  @doc """
  Renders a [Hero Icon](https://heroicons.com).

  Hero icons come in three styles – outline, solid, and mini.
  By default, the outline style is used, but solid an mini may
  be applied by using the `-solid` and `-mini` suffix.

  You can customize the size and colors of the icons by setting
  width, height, and background color classes.

  Icons are extracted from your `assets/vendor/heroicons` directory and bundled
  within your compiled app.css by the plugin in your `assets/tailwind.config.js`.

  ## Examples

      <.icon name="hero-x-mark-solid" />
      <.icon name="hero-arrow-path" class="w-3 h-3 ml-1 animate-spin" />
  """
  attr :id, :string, required: false
  attr :name, :string, required: true
  attr :class, :string, default: "h-5 w-5"

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class, "flex-shrink-0"]} />
    """
  end

  attr :class, :string, default: "max-w-7xl"
  slot :inner_block, required: true

  def container(assigns) do
    ~H"""
    <div class={["px-4 mx-auto sm:px-6 lg:px-8", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders a modal.

  ## Examples

      <.modal id="confirm-modal">
        This is a modal.
      </.modal>

  JS commands may be passed to the `:on_cancel` to configure
  the closing/cancel event, for example:

      <.modal id="confirm" on_cancel={JS.navigate(~p"/posts")}>
        This is another modal.
      </.modal>

  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :class, :string, default: nil
  attr :on_cancel, JS, default: %JS{}
  slot :inner_block, required: true

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      class={["relative z-40 hidden", @class]}
    >
      <div
        id={"#{@id}-overlay"}
        class="fixed inset-0 hidden bg-opacity-75 bg-zinc-600"
        aria-hidden="true"
      />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex items-center justify-center min-h-full">
          <div class="w-full h-full p-4 overflow-x-hidden sm:p-6 lg:py-8 sm:max-w-3xl sm:h-max sm:overflow-y-hidden">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
              phx-key="escape"
              phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
              class="relative hidden p-8 transition shadow-lg bg-zinc-900 text-zinc-100 ring-zinc-700/10 rounded-2xl sm:p-12 ring-1"
            >
              <div class="absolute top-6 right-5">
                <.button
                  phx-click={JS.exec("data-cancel", to: "##{@id}")}
                  type="button"
                  class="flex-none p-3 -m-3 opacity-20 hover:opacity-40"
                  aria-label="close"
                  color={nil}
                  size={nil}
                  class="p-1"
                >
                  <span class="sr-only">
                    Close panel
                  </span>
                  <.icon name="hero-x-mark-solid" class="w-5 h-5 opacity-40 group-hover:opacity-70" />
                </.button>
              </div>
              <div id={"#{@id}-content"}>
                <%= render_slot(@inner_block) %>
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, default: "flash", doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot(:inner_block, doc: "the optional inner block that renders the flash message")

  def flash(assigns) do
    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class={[
        "fixed bottom-5 left-5 w-80 sm:w-96 z-50 rounded-lg p-3 ring-1",
        @kind == :info && "bg-emerald-50 text-emerald-800 ring-emerald-500 fill-cyan-900",
        @kind == :error && "bg-rose-50 text-rose-900 shadow-md ring-rose-500 fill-rose-900"
      ]}
      {@rest}
    >
      <p :if={@title} class="flex items-center gap-1.5 text-sm font-semibold leading-6">
        <.icon :if={@kind == :info} name="hero-information-circle-mini" class="w-4 h-4" />
        <.icon :if={@kind == :error} name="hero-exclamation-circle-mini" class="w-4 h-4" />
        <%= @title %>
      </p>
      <p class="text-sm leading-5"><%= msg %></p>
      <button type="button" class="absolute top-0 p-2 group right-1" aria-label={gettext("close")}>
        <.icon name="hero-x-mark-solid" class="w-5 h-5 opacity-40 group-hover:opacity-70" />
      </button>
    </div>
    """
  end

  @doc """
  A generic dropdown menu component.

  The button slot provides an annonymous toggling function and an id that
  function targets, making them required attibutes to set on the slot for it to
  function.

  ## Examples

    <Components.menu>
      <:button :let={{toggle_menu, button_id}}>
        <Components.button id={button_id} phx-click={toggle_menu.()}>
          Open/close
        </Components.button>
      </:button>
      <:item>
        <.link>Menuitem 1</.link>
      </:item>
      <:item>Menuitem 2</:item>
    </Components.menu>

  """
  attr(:menu_items_wrapper_class, :string,
  default: "",
  doc: "any extra CSS class for menu item wrapper container"
)
  attr(:class, :string, default: "")
  attr(:id, :string, required: true)
  attr(:rest, :global)
  attr(:placement, :string, default: "left", values: ["left", "right"])

  slot(:trigger)
  slot :item do
    attr(:role, :string)
  end

  def menu(assigns) do
    ~H"""
    <div class="flex h-full">
      <div class="inline-block text-left group">
        <%= render_slot(@trigger, {fn -> toggle_menu(@id) end, @id <> "-button"}) %>

        <div
          id={@id}
          class={[placement_class(@placement),
            "absolute z-50 mt-2 w-full hidden border border-zinc-700
              bottom-auto transform inset-x-0
              bg-zinc-800 rounded-lg shadow-lg ring-1 min-w-max
              ring-black ring-opacity-5 focus:outline-none overflow-y-auto",
            @class
          ]}
          role="menu"
          aria-orientation="vertical"
          aria-labelledby={@id <> "-button"}
          phx-click-away={toggle_menu(@id)}
        >
          <.focus_wrap id={@id <> "-focus"}>
            <ul :if={not Enum.empty?(@item)} role="list" {@rest}>
              <li :for={item <- @item} class="flex flex-col" role={item[:role] || "listitem"}>
                <%= render_slot(item) %>
              </li>
            </ul>
          </.focus_wrap>
        </div>
      </div>
    </div>
    """
  end

  # .pc-dropdown__menu-items-wrapper {
  #   @apply absolute z-30 w-56 mt-2 bg-white rounded-md shadow-lg dark:bg-gray-800 ring-1 ring-black ring-opacity-5 focus:outline-none;
  # }
  # .pc-dropdown__menu-items-wrapper-placement--left {
  #   @apply right-0 origin-top-right;
  # }
  # .pc-dropdown__menu-items-wrapper-placement--right {
  #   @apply left-0 origin-top-left;
  # }

  defp placement_class("left"), do: "left-auto right-0 origin-top-right"
  defp placement_class("right"), do: "left-0 right-auto origin-top-left"

  attr :class, :string, default: ""
  attr :rest, :global, default: %{}, include: ~w(href navigate patch)
  slot :inner_block, required: true

  def menu_link(assigns) do
    ~H"""
    <.link
      class={[
        "m-1 flex items-center text-sm px-3 py-1 text-zinc-300 no-underline hover:bg-zinc-700 hover:text-zinc-200 focus:bg-zinc-700 focus:text-zinc-200 focus:ring-0 rounded-lg",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  attr(:class, :string, default: "")
  attr(:rest, :global)

  slot(:inner_block)

  def divider(assigns) do
    ~H"""
    <div class={["relative", @class]} {@rest}>
      <div class="absolute inset-0 flex items-center">
        <div class="w-full border-t border-zinc-600"></div>
      </div>
      <%= if @inner_block do %>
        <div class="relative flex justify-center">
          <span class="px-2 text-zinc-500">
            <%= render_slot(@inner_block) %>
          </span>
        </div>
      <% end %>
    </div>
    """
  end

  @doc """
  Tabs
  """

  attr :id, :string, required: true
  attr :type, :string, default: "button", values: ~w(button submit reset)
  attr :full, :boolean, default: false, doc: "forces the width to full"
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled)

  slot :tab, required: true do
    attr :disabled, :boolean
    attr :error, :boolean
    attr :selected, :boolean, doc: "activates the selected state"
  end

  def tabs(assigns) do
    ~H"""
    <nav class={@class} aria-label="Tabs">
      <div class="sm:hidden">
        <label for={"#{@id}-mobile"} class="sr-only">Select a tab</label>
        <select
          id={"#{@id}-mobile"}
          name={"#{@id}-mobile"}
          phx-change={JS.dispatch("js:tab-selected", detail: %{id: "#{@id}-mobile"})}
          class="block w-full py-2 pl-3 pr-10 text-base rounded-md border-zinc-300 focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm"
        >
          <option :for={{tab, i} <- Enum.with_index(@tab)} value={"#{@id}-#{i}"} selected={tab.selected}>
            <%= render_slot(tab) %>
          </option>
        </select>
      </div>
      <div class="hidden sm:block">
        <div class="flex space-x-8 overflow-x-auto snap-mandatory overscroll-x-contain scroll-px-6 lg:overflow-x-hidden">
          <.link
            :for={{tab, i} <- Enum.with_index(@tab)}
            id={"#{@id}-#{i}"}
            aria-current={tab[:selected] && "page"}
            phx-mounted={tab[:selected] && JS.dispatch("phx:scroll-into-view")}
            class={[
              "snap-start no-underline px-1 py-4 font-medium border-b-2 whitespace-nowrap",
              state_classes(tab),
              @full && "w-1/4 text-center"
            ]}
            {assigns_to_attributes(tab, [:selected, :disabled])}
          >
            <%= render_slot(tab) %>
            <.badge :if={tab[:badge]} class="ml-2">
              <%= tab.badge %>
            </.badge>
          </.link>
        </div>
      </div>
    </nav>
    """
  end

  defp state_classes(%{selected: true, error: true}) do
    "text-danger border-danger hover:text-danger-dark"
  end

  defp state_classes(%{selected: false, error: true}) do
    "text-danger border-transparent hover:text-danger-dark hover:border-danger"
  end

  defp state_classes(%{selected: true}) do
    "text-white border-white"
  end

  defp state_classes(%{disabled: true}) do
    "text-zinc-400 border-transparent cursor-not-allowed hover:border-transparent hover:text-zinc-400"
  end

  defp state_classes(_) do
    "text-zinc-500 border-transparent hover:text-zinc-400 hover:border-zinc-300"
  end

  @doc """
  Breadcrumb navigation component separated by auto-generated right chevrons.

  Raises an `ArgumentError` when no link slots are added to the
  breadcrumb.

  Assigns passed into the link slot are all bubbled down to
  `Phoenix.Component.link/1`.

  ## Examples

      <Components.breadcrumbs class="p-1">
        <:link patch={Routes.index_path(Endpoint, :index)}><%= gettext "Foo" %></:link>
        <:link><%= gettext "Foo" %></:link>
      </Components.breadcrumbs>

  """

  attr(:rest, :global, default: %{})

  slot(:link, required: true)

  def breadcrumbs(assigns) do
    assigns =
      assigns
      |> assign(:first, 0)
      |> assign(:last, length(assigns.link) - 1)
      |> assign(:penultimate, length(assigns.link) - 2)

    ~H"""
    <nav aria-label="Breadcrumb" {@rest}>
      <.link
        navigate={Enum.at(@link, @last)}
        class="flex no-underline truncate flex-shrink-1 sm:hidden text-zinc-400 hover:text-zinc-300"
      >
        <%= render_slot(Enum.at(@link, @last)) %>
      </.link>

      <ol role="list" class="flex items-center hidden h-4 space-x-3 text-sm sm:flex">
        <%= for {link, counter} <- Enum.with_index(@link) do %>
          <%= if counter > 0 do %>
            <svg
              class="flex-shrink-0 w-4 h-4 text-zinc-300"
              fill="currentColor"
              viewBox="0 0 20 20"
              aria-hidden="true"
            >
              <path d="M5.555 17.776l8-16 .894.448-8 16-.894-.448z" />
            </svg>
          <% end %>

          <li>
            <.link
              class={[
                "no-underline text-zinc-400 hover:text-zinc-300 truncate flex-shrink-1",
                counter == @last && "text-zinc-300 hover:text-zinc-200 "
              ]}
              {link}
            >
              <%= render_slot(link) %>
            </.link>
          </li>
        <% end %>
      </ol>
    </nav>
    """
  end

  @doc """
  Badge renders a colored pill span wrapping the content.

  Custom colors can be manually provided via the class attribute when a
  color assign is not set.

  ## Examples

      <Components.badge color={:blue}>Blue</Components.badge>
      <Components.badge color={:blue}>Red</Components.badge>
      <Components.badge>Grey</Components.badge>
      <Components.badge class="bg-pink-900 text-green">Custom</Components.badge>

  """
  attr :color, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block

  def badge(assigns) do
    ~H"""
    <span
      class={[
        "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium",
        !@color && "bg-zinc-100 text-zinc-800 dark:bg-zinc-800 dark:text-zinc-300",
        @color == "red" && "bg-red-100 text-red-800",
        @color == "yellow" && "bg-yellow-100 text-yellow-800",
        @color == "green" && "bg-green-100 text-green-800",
        @color == "blue" && "bg-blue-100 text-blue-800",
        @color == "indigo" && "bg-indigo-100 text-indigo-800",
        @color == "purple" && "bg-purple-100 text-purple-800",
        @color == "pink" && "bg-pink-100 text-pink-800",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  attr :id, :string
  slot :inner_block
  slot :aside_header
  slot :aside_content

  def slideover(assigns) do
    ~H"""
    <div
      id={"#{@id}-overlay"}
      class="fixed inset-0 z-10 hidden bg-opacity-75 bg-zinc-600"
      aria-hidden="true"
      phx-click={JS.exec("data-cancel", to: "##{@id}")}
    >
    </div>
    <div
      id={@id}
      role="dialog"
      aria-modal="true"
      aria-hidden="true"
      phx-remove={hide_slideover(@id)}
      data-cancel={JS.exec("phx-remove")}
      class={[
        "hidden fixed inset-y-0 z-20 flex max-w-full transition-transform",
        @direction == "right" && "right-0",
        @direction == "left" && "left-0"
      ]}
    >
      <.focus_wrap
        id={"#{@id}-container"}
        phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
        phx-key="escape"
        phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
        class="h-full"
      >
        <div class="w-screen h-full max-w-xs">
          <div class={[
            "flex flex-col h-full py-2.5 overflow-y-auto shadow-xl border-zinc-300 px-8 bg-zinc-900",
            @direction == "right" && "rounded-l-xl",
            @direction == "left" && "rounded-r-xl"
          ]}>
            <div class="flex items-start justify-between pt-2 pb-4">
              <h2 class="text-lg uppercase text-zinc-900 font-base">
                <%= render_slot(@aside_header) %>
              </h2>

              <div class="flex items-center h-7">
                <.button
                  type="button"
                  phx-click={hide_slideover(@id)}
                  color={nil}
                  size={nil}
                  class="p-1 mr-[-16px]"
                >
                  <span class="sr-only">
                    Close panel
                  </span>
                  <.icon name="hero-x-mark-solid" class="flex-shrink-0 w-5 h-5" />
                </.button>
              </div>
            </div>

            <%= render_slot(@inner_block) %>

            <div id={"#{@id}-content"}>
              <%= render_slot(@aside_content) %>
            </div>
          </div>
        </div>
      </.focus_wrap>
    </div>
    """
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-overlay",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-overlay",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end

  def toggle_menu(js \\ %JS{}, id) do
    js
    |> JS.remove_class("hidden", to: "##{id}.hidden")
    |> JS.add_class("hidden", to: "##{id}:not(.hidden)")
    |> JS.remove_class("text-violet-500", to: "##{id}-button.text-violet-500")
    |> JS.add_class("text-violet-500", to: "##{id}-button:not(.text-violet-500)")
  end

  def show_slideover(js \\ %JS{}, id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(to: "##{id}-overlay")
    |> JS.set_attribute({"aria-hidden", false}, to: "##{id}")
    |> JS.set_attribute({"aria-hidden", false}, to: "#{id}-overlay")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_slideover(js \\ %JS{}, id) do
    js
    |> JS.hide(to: "##{id}")
    |> JS.hide(to: "##{id}-overlay")
    |> JS.set_attribute({"aria-hidden", true}, to: "##{id}")
    |> JS.set_attribute({"aria-hidden", true}, to: "#{id}-overlay")
    |> JS.pop_focus()
  end
end
