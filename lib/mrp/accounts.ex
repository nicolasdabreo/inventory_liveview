defmodule MRP.Accounts do
  use MRP, :context

  alias MRP.Accounts.User
  alias MRP.Accounts.Email
  alias MRP.Accounts.Password
  alias MRP.Accounts.Authentication.UserToken

  def get_user_by_primary_email(email) when is_binary(email) do
    email_subquery = from e in Email, where: e.email == ^email

    query =
      from u in User,
        join: primary_email in subquery(email_subquery),
        on: u.id == primary_email.user_id,
        preload: [:primary_email, :password]

    Repo.one(query)
  end

  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    with user when not is_nil(user) <- get_user_by_primary_email(email) do
      if Password.valid_password?(user.password, password), do: user
    end
  end

  def get_user!(id), do: Repo.get!(User, id)

  def register_user_with_password(attrs) do
    %User{}
    |> User.password_registration_changeset(attrs)
    |> Repo.insert()
  end

  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.password_registration_changeset(user, attrs)
  end

  @doc ~S"""
  Delivers the verification email instructions to the given user.
  """
  def deliver_email_verification_instructions(%Email{email: email, verified_at: nil}, verification_url_fun)
    when is_function(verification_url_fun, 1) do
    user = Accounts.get_user_by_linked_email(email)
    {encoded_token, user_token} = UserToken.build_user_token(user, "verify")
    Repo.insert!(user_token)

    Mailer.send(Emails.UserverificationInstructions, %{
      to: email.email,
      url: verification_url_fun.(encoded_token)
    })
  end

  def deliver_email_verification_instructions(%Email{verified_at: _not_nil}, _verification_url_fun) do
    {:error, :already_verified}
  end

  @doc """
  verifies an email by the given token. If the token matches, the email is
  marked as verified and the token is deleted.
  """
  def verify_user(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "verify"),
         %Email{} = email <- Repo.one(query),
         {:ok, %{user: email}} <- Repo.transaction(verify_user_multi(user)) do
      {:ok, email}
    else
      _ -> :error
    end
  end

  defp verify_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:email, Email.verify_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, ["verify"]))
  end
end
