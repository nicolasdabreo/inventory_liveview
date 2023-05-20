defmodule Mailer.Email do
  @moduledoc """
  A module for sending emails using the Swoosh and Oban libraries.

  To use this module, define an `Email` Oban worker with the appropriate args
  for the email's content and settings. Then use this module as your
  interface to the Swoosh mailer.
  """

  use Swoosh.Mailer, otp_app: :mrp

  defmacro __using__(_) do
    quote do
      use Oban.Worker, queue: :mailer, max_attempts: 5
      use Phoenix.Component

      import Swoosh.Email
      import Elixir.Mailer.HTML
      import Elixir.Mailer.Email
    end
  end
end
