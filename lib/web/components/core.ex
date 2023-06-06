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
      <div class="mt-10 space-y-8 bg-white">
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
  attr(:color, :string, default: "violet-500")
  attr(:patch, :string, default: nil)
  attr(:navigate, :string, default: nil)
  attr(:href, :string, default: nil)

  attr(:full, :boolean,
    default: false,
    doc: "forces the width to full, tip: add sm:w-max to have it be full only on mobile"
  )

  attr :class, :string, default: nil
  attr :rest, :global

  slot(:inner_block, required: true)

  def button(%{patch: nil, navigate: nil, href: nil} = assigns) do
    ~H"""
    <button
      class={[
        button_base_classes(),
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
        button_base_classes(),
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

  defp button_base_classes do
    "inline-flex items-center font-semibold no-underline border border-transparent border border-zinc-300 rounded-md shadow-lg disabled:text-gray-400 disabled:bg-gray-200 disabled:hover:bg-gray-200 disabled:cursor-not-allowed phx-submit-loading:opacity-75"
  end

  defp button_size_classes("sm"), do: "h-8 px-3 py-2 text-sm"
  defp button_size_classes("md"), do: "h-10 px-4 py-2 text-base"
  defp button_size_classes("lg"), do: "h-12 px-6 py-2 text-lg"
  defp button_size_classes(_size), do: ""

  defp button_color_classes("violet-500"),
    do:
      "bg-violet-500 text-white hover:text-slate-100 hover:bg-violet-500 active:bg-violet-800 active:text-violet-100"

  defp button_color_classes("blue"),
    do:
      "bg-blue-600 text-white hover:text-slate-100 hover:bg-blue-500 active:bg-blue-800 active:text-blue-100"

  defp button_color_classes("gray"),
    do:
      "bg-slate-900 text-white hover:bg-slate-700 hover:text-slate-100 active:bg-slate-800 active:text-slate-300"

  defp button_color_classes("white"),
    do:
      "bg-white text-slate-900 hover:bg-blue-50 active:bg-blue-200 active:text-slate-600 border border-slate-300"

  defp button_color_classes(_size), do: ""

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
        <h1 class="text-lg font-semibold leading-8 text-zinc-800">
          <%= render_slot(@inner_block) %>
        </h1>
        <p :if={@subtitle != []} class="mt-2 text-sm leading-6 text-zinc-600">
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
    <div class="mt-16">
      <.link
        navigate={@navigate}
        class={["text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700", @class]}
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

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def container(assigns) do
    ~H"""
    <div class={["px-4 mx-auto max-w-7xl sm:px-6 lg:px-8", @class]}>
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
      <div id={"#{@id}-bg"} class="fixed inset-0 transition-opacity bg-zinc-50/90" aria-hidden="true" />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex items-center justify-center min-h-full">
          <div class="w-full max-w-3xl p-4 sm:p-6 lg:py-8">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
              phx-key="escape"
              phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
              class="relative hidden transition bg-white shadow-lg shadow-zinc-700/10 ring-zinc-700/10 rounded-2xl p-14 ring-1"
            >
              <div class="absolute top-6 right-5">
                <button
                  phx-click={JS.exec("data-cancel", to: "##{@id}")}
                  type="button"
                  class="flex-none p-3 -m-3 opacity-20 hover:opacity-40"
                  aria-label="close"
                >
                  <.icon name="hero-x-mark-solid" class="w-5 h-5" />
                </button>
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
        "fixed top-2 right-2 w-80 sm:w-96 z-50 rounded-lg p-3 ring-1",
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
      <p class="mt-2 text-sm leading-5"><%= msg %></p>
      <button type="button" class="absolute p-2 group top-1 right-1" aria-label={gettext("close")}>
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
  attr(:class, :string, default: "")
  attr(:rest, :global)
  slot(:button)

  slot :item do
    attr(:role, :string)
  end

  def menu(assigns) do
    assigns = assign_new(assigns, :id, fn -> "menu-#{System.unique_integer([:positive])}" end)

    ~H"""
    <div class="flex">
      <div class="inline-block text-left group">
        <%= render_slot(@button, {fn -> toggle_menu(@id) end, @id <> "-button"}) %>

        <div
          id={@id}
          class={[
            "z-50 absolute mt-2 w-full hidden
              left-auto bottom-auto right-0 origin-top-right transform inset-x-0
              scale-100 bg-white rounded-lg shadow-lg opacity-100 ring-1 min-w-max
              ring-black ring-opacity-5 focus:outline-none p-0 overflow-y-auto",
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

  attr :class, :string, default: ""
  attr :rest, :global, default: %{}, include: ~w(href navigate patch)
  slot :inner_block, required: true

  def menu_link(assigns) do
    ~H"""
    <.link
      class={[
        "block px-4 py-2 text-gray-700 no-underline hover:bg-gray-100 hover:text-gray-900 focus:bg-gray-100 focus:text-gray-900 focus:ring-0",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  attr(:class, :string, default: "py-4")
  attr(:rest, :global)

  slot(:inner_block)

  def divider(assigns) do
    ~H"""
    <div class={["relative", @class]} {@rest}>
      <div class="absolute inset-0 flex items-center">
        <div class="w-full border-t border-gray-300"></div>
      </div>
      <%= if @inner_block do %>
        <div class="relative flex justify-center">
          <span class="px-2 text-gray-500">
            <%= render_slot(@inner_block) %>
          </span>
        </div>
      <% end %>
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
      to: "##{id}-bg",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
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
end
