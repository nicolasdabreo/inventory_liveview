defmodule Mailer.Emails.UserUpdateEmailInstructions do
  @moduledoc """
  Oban worker for creating a email for updating a users email address.
  """

  use Mailer.Email

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"to" => to, "url" => url}}) do
    base_email_from_noreply(to)
    |> subject("Update email instructions")
    |> text_body("""
    Hi #{to},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.
    """)
    |> render_with_layout(:user_update_email_instructions, %{to: to, url: url})
    |> deliver()
  end
end
