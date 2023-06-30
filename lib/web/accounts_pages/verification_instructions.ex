defmodule Web.Pages.AuthenticationLive.VerificationInstructions do
  use Web, :live_view

  alias MRP.Accounts
  alias MRP.Accounts.User
  alias MRP.Accounts.Email

  def render(assigns) do
    ~H"""
    <.header>Resend confirmation instructions</.header>

    <.simple_form for={@form} id="resend_confirmation_form" phx-submit="send_instructions">
      <.input field={@form[:email]} type="email" label="Email" required />
      <:actions>
        <.button phx-disable-with="Sending...">Resend confirmation instructions</.button>
      </:actions>
    </.simple_form>

    <p>
      <.link href={~p"/register"}>Register</.link> | <.link href={~p"/login"}>Log in</.link>
    </p>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_instructions", %{"user" => %{"email" => given_email}}, socket) do
    with %User{} = user <- Accounts.get_user_by_email(given_email),
         %Email{} = email <- Accounts.get_unverified_email_for_user(user),
         true <- email.email == given_email do
      Accounts.deliver_email_verification_instructions(
        user,
        email,
        &url(~p"/emails/verify/#{&1}")
      )
    end

    info =
      "If your email is in our system and it has not been verified yet, you will receive an email with instructions shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
