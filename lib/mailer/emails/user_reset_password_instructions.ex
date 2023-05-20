defmodule Mailer.Emails.UserResetPasswordInstructions do
  @moduledoc """
  Oban worker for creating a reset password email
  """

  use Mailer.Email

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"to" => to, "url" => url}}) do
    base_email_from_noreply(to)
    |> subject("Reset password instructions")
    |> text_body("""
    Hi #{to},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.
    """)
    |> render_with_layout(:user_reset_password_instructions, %{to: to, url: url})
    |> deliver()
  end
end
