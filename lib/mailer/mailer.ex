defmodule Mailer do
  @moduledoc """
  Entrypoint for singular and mass Emailing logic
  """

  @doc """
  Enqueues a Job to send an email to via the given Worker module.

  ## Examples

      iex> Email.send(Emails.Test, %{to: "foo@bar.com"})
      {:ok, %Oban.Job{args: %{to: "foo@bar.com"}}}
  """
  def send(module, assigns) do
    assigns
    |> module.new()
    |> Oban.insert()
  end
end
