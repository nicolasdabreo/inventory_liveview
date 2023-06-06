defmodule Mailer.Emails.EmailVerificationInstructions do
  @moduledoc """
  Oban worker for creating an email address verification email
  """

  use Mailer.Email

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"to" => to, "url" => url}}) do
    to
    |> base_email_from_noreply()
    |> subject("Verification instructions")
    |> text_body("""
    Hi #{to},

    An email address has been added to your account you can verify this email by visiting the URL below:

    #{url}

    If you didn't add this email address, please ignore this.
    """)
    |> render_with_layout(:email_verification_instructions, %{to: to, url: url})
    |> deliver()
  end
end
