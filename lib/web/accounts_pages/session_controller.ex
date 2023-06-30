defmodule Web.Pages.AuthenticationLive.SessionController do
  use Web, :controller

  import Web.Authenticate

  alias MRP.Accounts
  alias MRP.Accounts.User

  alias Web.Authenticate
  alias Web.Forms.LoginForm

  plug :redirect_if_user_is_authenticated when action in [:create]

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Account created successfully!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    create(conn, params, "Password updated successfully!")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, %{"user" => user_params}, info) do
    email = user_params["email"]

    with {:ok, %{email: email, password: password}} <- LoginForm.attributes(user_params),
         %User{} = user <- Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, info)
      |> Authenticate.log_in_user(user, user_params)
    else
      _ ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> put_flash(:email, String.slice(email, 0, 160))
        |> redirect(to: ~p"/login")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> Authenticate.log_out_user()
  end
end
