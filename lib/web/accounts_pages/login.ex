defmodule Web.Pages.AuthenticationLive.Login do
  use Web, :live_view

  alias Web.Forms.LoginForm

  def render(assigns) do
    ~H"""
    <div>
      <.header class="text-center">
        Welcome back
      </.header>

      <.simple_form
        for={@form}
        id={"login_form_#{@live_action}"}
        action={~p"/login"}
        phx-update="ignore"
        method="post"
      >
        <.input field={@form[:email]} type="email" label="Email" required autofocus />
        <.input field={@form[:password]} type="password" label="Password" required />

        <div class="mt-10 text-sm text-center">
          <.link href={} class="font-semibold text-violet-500 hover:underline">
            Forgot your password?
          </.link>
        </div>

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
        Not a customer yet?
        <.link navigate={~p"/register"} class="font-semibold text-violet-500 hover:underline">
          Sign up
        </.link>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = LoginForm.form(%{"email" => email})
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end

  def handle_event(_event, _params, socket) do
    {:noreply, socket}
  end
end
