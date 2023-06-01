defmodule Web.Pages.AuthenticationLive.Registration do
  use Web, :live_view

  import Web.Pages.AuthenticationLive.Components

  alias MRP.Accounts
  alias MRP.Accounts.User

  def render(assigns) do
    ~H"""
    <div>
      <.header class="text-center">
        Create an account
        <:subtitle>
          We require you to confirm your email address after registration, so make sure its correct!
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        method="post"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <%= case @live_action do %>
          <% :identifier -> %>
            <.inputs_for :let={pef} field={@form[:primary_email]}>
              <.input
                field={pef[:email]}
                value={@email}
                type="email"
                label="Email"
                required
                autofocus
              />
            </.inputs_for>
          <% :password -> %>
            <.inputs_for :let={pef} field={@form[:primary_email]}>
              <.input field={pef[:email]} type="hidden" value={@email} />
              <.input field={pef[:email]} value={@email} type="email" label="Email" disabled>
                <:trailing>
                  <.link
                    class="px-1 m-2 rounded-md text-violet-500 hover:bg-zinc-50"
                    patch={~p"/login/identifier"}
                  >
                    Edit
                  </.link>
                </:trailing>
              </.input>
            </.inputs_for>

            <.inputs_for :let={pf} field={@form[:password]}>
              <.input field={pf[:password]} type="password" label="Password" required />
            </.inputs_for>
        <% end %>

        <:actions>
          <.button
            type="submit"
            phx-disable-with="Continuing..."
            class="justify-center w-full gap-x-1"
          >
            Continue <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>

      <div class="mt-10 text-sm text-center">
        <%= case @live_action do %>
          <% :identifier -> %>
            Already registered?
            <.link navigate={~p"/login/identifier"} class="font-semibold text-violet-500">
              Log in
            </.link>
          <% :password -> %>
            <.link href={} class="font-semibold">
              Forgot your password?
            </.link>
        <% end %>
      </div>

      <div :if={@live_action == :identifier} class="mt-10">
        <div class="relative">
          <div class="absolute inset-0 flex items-center" aria-hidden="true">
            <div class="w-full border-t border-gray-200"></div>
          </div>
          <div class="relative flex justify-center text-sm font-medium leading-6">
            <span class="px-6 text-gray-900 bg-white">Or continue with</span>
          </div>
        </div>

        <.oauth_providers />
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(:page_title, "Create account")
      |> assign(trigger_submit: false, check_errors: false)
      |> assign(email: nil)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user_with_password(user_params) do
      {:ok, user} ->
        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
