defmodule Mailer.Emails.UserConfirmationInstructions do
  @moduledoc """
  Oban worker for creating a user confirmation email
  """

  use Mailer.Email

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"to" => to, "url" => url}}) do
    to
    |> base_email_from_noreply()
    |> subject("Confirmation instructions")
    |> text_body("""
    Hi #{to},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.
    """)
    |> render_with_layout(:user_confirmation_instructions, %{to: to, url: url})
    |> deliver()
  end
end
