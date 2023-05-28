# credo:disable-for-this-file Credo.Check.Refactor.ModuleDependencies
defmodule Web.Router do
  use Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", Web.Pages do
    pipe_through [:browser]

    live_session :marketing do
      live "/", LandingLive
    end
  end

  scope "/", Web.Pages.AuthenticationLive do
    pipe_through [:browser]

    delete "/logout", SessionController, :delete
    post "/login", SessionController, :create
    # get "/oauth/callbacks/:provider", OAuthCallbackController, :new

    live_session :authentication do
      live "/login/identifier", Login, :identifier
      live "/login/password", Login, :password
      live "/login/organisations", Organisations, :index
      live "/register/identifier", Registration, :identifier
      live "/register/password", Registration, :password
    end
  end

  scope "/", Web.TenantPages do
    pipe_through [:browser]
  end

  # Redirects

  scope "/", Web do
    get "/login", Redirect, to: "/login/identifier"
    get "/register", Redirect, to: "/register/identifier"
  end

  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
