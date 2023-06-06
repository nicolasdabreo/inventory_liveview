defmodule MRP.Accounts do
  use MRP, :context

  alias MRP.Accounts.User
  alias MRP.Accounts.Email
  alias MRP.Accounts.Password
  alias MRP.Accounts.Authentication.UserToken

  @doc """
  A user should only ever have a single unverified email address at once, this
  function retrieves that unverified email address.
  """
  def get_unverified_email_for_user(%User{} = user) do
    query =
      from(e in Email,
      join: u in assoc(e, :user),
      where: is_nil(e.verified_at),
      where: u.id == ^user.id)


    Repo.one(query)
  end

  def get_user_by_primary_email(email) when is_binary(email) do
    query =
      from u in User,
      join: e in Email,
      on: u.id == e.user_id,
      where: e.email == ^email,
      where: "primary" in e.tags,
      preload: [:primary_email, :password]

    Repo.one(query)
  end

  def get_user_by_email(email) when is_binary(email) do
    query =
      from u in User,
      join: e in Email,
      on: u.id == e.user_id,
      where: e.email == ^email

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
  def deliver_email_verification_instructions(user, %Email{verified_at: nil} = email, verification_url_fun)
    when is_function(verification_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, email, "verify")
    Repo.insert!(user_token)

    Mailer.send(Emails.EmailVerificationInstructions, %{
      to: email.email,
      url: verification_url_fun.(encoded_token)
    })
  end

  def deliver_email_verification_instructions(_user, %Email{verified_at: _not_nil}, _verification_url_fun) do
    {:error, :already_verified}
  end

  @doc """
  verifies an email by the given token. If the token matches, the email is
  marked as verified and the token is deleted.
  """
  def verify_email(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "verify") ,
         %User{} = user <- Repo.one(query) ,
         %Email{} = email <- get_unverified_email_for_user(user) ,
         {:ok, %{email: email}} <- Repo.transaction(verify_email_multi(user, email))  do
      {:ok, email}
    else
      _ -> :error
    end
  end

  defp verify_email_multi(user, email) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:email, Email.verify_changeset(email))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, ["verify"]))
  end
end
