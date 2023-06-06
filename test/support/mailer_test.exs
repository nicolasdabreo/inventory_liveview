defmodule MailerTest do
  use MRP.DataCase, async: true
  use Oban.Testing, repo: MRP.Repo

  import Swoosh.TestAssertions

  alias Mailer.Emails

  describe "send/2" do
    test "enqueues an Oban Job for the given email" do
      Oban.Testing.with_testing_mode(:manual, fn ->
        Mailer.send(Emails.UserConfirmationInstructions, %{to: "foo@bar.com", url: "asdf.com"})

        assert_enqueued(
          worker: Emails.UserConfirmationInstructions,
          args: %{to: "foo@bar.com", url: "asdf.com"}
        )
      end)
    end

    test "processing an email Job sends an email to the mailbox" do
      Oban.Testing.with_testing_mode(:manual, fn ->
        Mailer.send(Emails.UserConfirmationInstructions, %{to: "foo@bar.com", url: "asdf.com"})
        Oban.drain_queue(queue: :mailer)

        assert_email_sent(fn email ->
          assert email.to == [{"", "foo@bar.com"}]
          assert email.subject == "Confirmation instructions"
        end)
      end)
    end
  end
end
