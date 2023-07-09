defmodule Web.Pages.OnboardingLive do
  @moduledoc """
  LiveView that is shown on initial log in of the origin owner account.

  Collects the information necessary to set up a new tenant via a multistep
  form. Company branding and domain w/ preview, supported corp auth options.
  """

  use Web, :live_view

  alias Web.Pages.OnboardingForm

  def render(assigns) do
    ~H"""
    <.container class="max-w-xl mt-20">
      <div>Step 1 / 2</div>
      <div class="grid grid-cols-1">
        <.simple_form
          for={@form}
          id={"onboarding_form_#{@live_action}"}
          class="grid grid-cols-3 gap-x-3"
          phx-update="validate"
          phx-submit="save"
        >
          <.header class="col-span-3">
            Onboarding
            <:subtitle>Configure your company branding</:subtitle>
          </.header>

          <%= case @live_action do %>
            <% :brand -> %>
              <div class="col-span-2">
                <.input field={@form[:domain]} type="text" label="Subdomain" required autofocus />
              </div>

              <div class="col-span-1">
                <.input field={@form[:brand_color]} type="color" label="Brand color" />
              </div>

              <div class="col-span-3">
                <.input field={@form[:logo]} type="file" label="Company logo" />
              </div>
            <% :auth -> %>
              <div />
          <% end %>

          <:actions>
            <.button
              type="submit"
              phx-disable-with="Configuring..."
              class="justify-center w-full gap-x-1"
            >
              Continue
            </.button>
          </:actions>
          <:actions>
            <.link class="flex items-center text-sm font-normal text-zinc-500">
              Skip <span class="ml-2" aria-hidden="true">→</span>
            </.link>
          </:actions>
        </.simple_form>
      </div>
    </.container>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket, layout: {Web.Components.Layouts, :empty}}
  end

  def handle_params(params, _uri, socket) do
    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :brand, _params) do
    form = OnboardingForm.form(:brand)

    socket
    |> assign(:page_title, "Onboarding")
    |> assign(:form, form)
  end

  defp apply_action(socket, :auth, _params) do
    form = OnboardingForm.form(:auth)

    socket
    |> assign(:page_title, "Onboarding")
    |> assign(:form, form)
  end

  def handle_event("validate", %{"onboarding" => params}, socket) do
    form = OnboardingForm.form(socket.assigns.live_action, params)

    {:noreply,
     socket
     |> assign(:form, form)}
  end
end
