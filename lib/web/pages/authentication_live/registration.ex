defmodule Web.Pages.AuthenticationLive.Registration do
  use Web, :live_view

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

        <.inputs_for :let={pf} field={@form[:password]}>
          <.input field={pf[:password]} type="password" label="Password" required />
        </.inputs_for>

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
            <.link navigate={~p"/login/identifier"} class="font-semibold text-violet-500">
              Log in
            </.link>
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
