defmodule MRP.Accounts do
  use MRP, :context

  alias MRP.Accounts.User
  alias MRP.Accounts.Email
  alias MRP.Accounts.Password

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
end
