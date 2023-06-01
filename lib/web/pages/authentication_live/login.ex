defmodule Web.Pages.AuthenticationLive.Login do
  use Web, :live_view

  import Web.Pages.AuthenticationLive.Components

  alias MRP.Accounts.Email

  def render(assigns) do
    ~H"""
    <div>
      <.header class="text-center">
        Welcome back
      </.header>

      <.simple_form
        for={@form}
        id={"login_form_#{@live_action}"}
        action={@form_action}
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        method="post"
      >
        <%= case @live_action do %>
          <% :identifier -> %>
            <.input
              field={@form[:email]}
              value={@email}
              type="email"
              label="Email"
              required
              autofocus
            />
          <% :password -> %>
            <.input field={@form[:email]} type="hidden" value={@email} />
            <.input field={nil} name={nil} value={@email} type="email" label="Email" disabled>
              <:trailing>
                <.link
                  class="px-1 m-2 text-sm font-semibold rounded-md text-violet-500 hover:underline"
                  patch={~p"/login/identifier"}
                >
                  Edit
                </.link>
              </:trailing>
            </.input>
            <.input field={@form[:password]} type="password" label="Password" required />

            <div :if={@live_action == :password} class="mt-10 text-sm text-center">
              <.link href={} class="font-semibold text-violet-500 hover:underline">
                Forgot your password?
              </.link>
            </div>
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

      <div :if={@live_action == :identifier} class="mt-10 text-sm text-center">
        Don't have an account?
        <.link
          navigate={~p"/register/identifier"}
          class="font-semibold text-violet-500 hover:underline"
        >
          Sign up
        </.link>
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
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")

    {:ok,
     socket
     |> assign(:page_title, "Login")
     |> assign(:form_action, nil)
     |> assign(:trigger_submit, false)
     |> assign(:email, email), temporary_assigns: [form: form]}
  end

  def handle_params(_uri, params, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :identifier, _params) do
    socket
  end

  defp apply_action(socket, :password, _params) do
    if socket.assigns.email do
      assign(socket, :form_action, "/login")
    else
      push_patch(socket, to: ~p"/login/identifier")
    end
  end

  defp apply_action(socket, _invalid_action, _params) do
    push_patch(socket, to: ~p"/login/identifier")
  end

  def handle_event(
        "validate",
        %{"user" => user_params},
        %{assigns: %{live_action: :identifier}} = socket
      ) do
    changeset = Email.email_changeset(%Email{}, user_params, validate_email: false)
    {:noreply, assign(socket, :form, to_form(changeset, as: "user"))}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "save",
        %{"user" => user_params},
        %{assigns: %{live_action: :identifier}} = socket
      ) do
    changeset =
      %Email{}
      |> Email.email_changeset(user_params, validate_email: false)
      |> Map.put(:action, :validate)

    email = Ecto.Changeset.get_change(changeset, :email)
    socket = assign(socket, :email, email)

    if changeset.valid? do
      {:noreply, push_patch(socket, to: ~p"/login/password")}
    else
      {:noreply, assign(socket, :form, to_form(changeset, as: "user"))}
    end
  end

  def handle_event("save", _params, %{assigns: %{live_action: :password}} = socket) do
    {:noreply, assign(socket, :trigger_submit, true)}
  end

  def handle_event(_event, _params, socket) do
    {:noreply, socket}
  end
end
