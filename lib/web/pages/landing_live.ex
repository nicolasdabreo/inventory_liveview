defmodule Web.Pages.LandingLive do
  @moduledoc false

  use Web, :live_view

  alias Web.Components.Layouts

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Welcome to MRP!"), layout: {Layouts, :empty}}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.navbar current_user={@current_user} />

    <main>
      <div class="px-4 py-20 bg-violet-50 sm:px-6 lg:px-8">
        <.hero />
        <.primary_features />
      </div>
    </main>

    <.footer />
    """
  end

  defp navbar(assigns) do
    ~H"""
    <header class="py-6 md:py-10 bg-violet-50">
      <.container>
        <nav class="flex flex-row justify-between">
          <div class="flex flex-row items-center lg:gap-x-12">
            <a href="/">
              <div class="flex items-center flex-shrink-0">
                <img
                  class="block w-auto h-8 lg:hidden"
                  src="https://tailwindui.com/img/logos/mark.svg?color=violet&shade=500"
                  alt="Your Company"
                />
                <img
                  class="hidden w-auto h-8 lg:block"
                  src="https://tailwindui.com/img/logos/mark.svg?color=violet&shade=500"
                  alt="Your Company"
                />
              </div>
            </a>
            <div class="hidden lg:flex w-fit lg:gap-x-6">
              <.nav_link href="#features">
                Features <.icon name="hero-chevron-down" class="ml-1 text-slate-400" />
              </.nav_link>
              <.nav_link href="#testimonials">About Us</.nav_link>
              <.nav_link href="#pricing">Resouces & Support</.nav_link>
            </div>
          </div>

          <div class="flex items-center gap-x-5 lg:gap-x-8">
            <div class="hidden md:block">
              <.nav_link navigate="/login">Sign in</.nav_link>
            </div>

            <.button class="hidden md:block" navigate="/register">
              <span>
                Get started <span class="hidden lg:inline">today</span>
              </span>
            </.button>
            <.link class="flex inline-flex items-center justify-center p-2 text-zinc-700 rounded-md lg:hidden hover:text-violet-500">
              <span class="sr-only">Open main menu</span>
              <.icon name="hero-bars-3-solid" class="h-7 w-7" />
            </.link>
          </div>
        </nav>
      </.container>
    </header>
    """
  end

  attr :class, :string, default: ""
  attr :rest, :global, default: %{}, include: ~w(href navigate patch method)

  slot :inner_block, required: true

  defp nav_link(assigns) do
    ~H"""
    <.link
      class={[
        "inline-block font-semibold px-2 py-1 text-base text-slate-700 hover:text-violet-500",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  defp hero(assigns) do
    ~H"""
    <.container class="pt-20 pb-16 text-center lg:pt-32">
      <h1 class="max-w-4xl mx-auto text-5xl font-medium tracking-tight font-display text-slate-900 sm:text-7xl">
        Manufacturing
        <span class="relative text-violet-500 whitespace-nowrap">
          <svg
            aria-hidden="true"
            viewBox="0 0 418 42"
            class="absolute left-0 top-2/3 h-[0.58em] w-full fill-violet-300/70"
            preserveAspectRatio="none"
          >
            <path d="M203.371.916c-26.013-2.078-76.686 1.963-124.73 9.946L67.3 12.749C35.421 18.062 18.2 21.766 6.004 25.934 1.244 27.561.828 27.778.874 28.61c.07 1.214.828 1.121 9.595-1.176 9.072-2.377 17.15-3.92 39.246-7.496C123.565 7.986 157.869 4.492 195.942 5.046c7.461.108 19.25 1.696 19.17 2.582-.107 1.183-7.874 4.31-25.75 10.366-21.992 7.45-35.43 12.534-36.701 13.884-2.173 2.308-.202 4.407 4.442 4.734 2.654.187 3.263.157 15.593-.78 35.401-2.686 57.944-3.488 88.365-3.143 46.327.526 75.721 2.23 130.788 7.584 19.787 1.924 20.814 1.98 24.557 1.332l.066-.011c1.201-.203 1.53-1.825.399-2.335-2.911-1.31-4.893-1.604-22.048-3.261-57.509-5.556-87.871-7.36-132.059-7.842-23.239-.254-33.617-.116-50.627.674-11.629.54-42.371 2.494-46.696 2.967-2.359.259 8.133-3.625 26.504-9.81 23.239-7.825 27.934-10.149 28.304-14.005.417-4.348-3.529-6-16.878-7.066Z" />
          </svg>
          <span class="relative">made simple</span>
        </span>
        for small businesses.
      </h1>
      <p class="max-w-2xl mx-auto mt-6 text-lg tracking-tight text-slate-700">
        Plan, execute and deliver, with the adaptability to tackle any handle
        any situation.
      </p>
      <div class="flex justify-center mt-10 gap-x-6">
        <.button navigate="/register" color="gray">Get 1 month free</.button>
        <.button navigate={~p"/"} variant="outline" color="white">
          <.icon name="hero-play-solid" class="w-4 h-4" />
          <span class="ml-3">Watch video</span>
        </.button>
      </div>
      <div class="mt-36 lg:mt-44">
        <p class="text-base font-display text-slate-900">
          Trusted by these six companies so far
        </p>
        <ul
          role="list"
          class="flex items-center justify-center mt-8 gap-x-8 sm:flex-col sm:gap-x-0 sm:gap-y-10 xl:flex-row xl:gap-x-12 xl:gap-y-0"
        >
          <li :for={company <- ["Big company"]}>
            <ul
              role="list"
              class="flex flex-col items-center gap-y-8 sm:flex-row sm:gap-x-12 sm:gap-y-0"
            >
              <li class="flex items-center font-semibold text-orange-500 gap-x-2 text-uppercase">
                <img src={~p"/images/logo.svg"} class="w-auto h-10" /> <%= company %>
              </li>
            </ul>
          </li>
        </ul>
      </div>
    </.container>
    """
  end

  defp primary_features(assigns) do
    ~H"""

    """
  end

  defp footer(assigns) do
    ~H"""

    """
  end
end
