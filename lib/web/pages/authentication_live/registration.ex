defmodule Web.Pages.AuthenticationLive.Registration do
  use Web, :live_view

  alias MRP.Accounts
  alias Web.Forms.RegistrationForm

  def render(assigns) do
    ~H"""
    <div>
      <.header class="text-center">
        Start your 1 month free trial
        <:subtitle>
          We'll get in contact to confirm your account after registration, so make sure your email is correct!
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/login?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input
          field={@form[:email]}
          type="email"
          label="Email"
          required
          autofocus
        />

        <.input field={@form[:password]} type="password" label="Password" required />

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
        Already a customer?
        <.link navigate={~p"/login"} class="font-semibold text-violet-500">
          Log in
        </.link>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    form = RegistrationForm.form(%{})

    socket =
      socket
      |> assign(:page_title, "Create account")
      |> assign(trigger_submit: false, check_errors: false)
      |> assign(email: nil)
      |> assign(form: form)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => params}, socket) do
    with {:ok, attributes} <- RegistrationForm.attributes(params) |> IO.inspect(),
      {:ok, user} <- Accounts.register_user_with_password(attributes) |> IO.inspect() do
        {:ok, _} =
          Accounts.deliver_email_verification_instructions(
            user,
            user.primary_email,
            &url(~p"/emails/verify/#{&1}")
          )
          |> IO.inspect()

        form = RegistrationForm.form()
        {:noreply, socket |> assign(form: form, trigger_submit: true)}
      else
        {:error, %Ecto.Changeset{}} ->
          form = RegistrationForm.form(params)
          {:noreply, socket |> assign(form: form, check_errors: true)}
    end
  end

  def handle_event("validate", %{"user" => params}, socket) do
    form = RegistrationForm.form(params) |> IO.inspect()
    {:noreply, assign(socket, :form, form)}
  end
end
