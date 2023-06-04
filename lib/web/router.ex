# credo:disable-for-this-file Credo.Check.Refactor.ModuleDependencies
defmodule Web.Router do
  use Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {Web.Components.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Cldr.Plug.AcceptLanguage, cldr_backend: Web.Cldr
    plug Web.Plugs.I18n
  end

  scope "/", Web.Pages do
    pipe_through [:browser]

    live_session :marketing, on_mount: [Web.Assigns] do
      live "/", LandingLive
    end
  end

  scope "/", Web.Pages.AuthenticationLive do
    pipe_through [:browser]

    delete "/logout", SessionController, :delete
    post "/login", SessionController, :create
    # get "/oauth/callbacks/:provider", OAuthCallbackController, :new

    live_session :authentication,
      on_mount: [Web.Assigns],
      layout: {Web.Components.Layouts, :auth} do
      live "/login/identifier", Login, :identifier
      live "/login/password", Login, :password
      live "/register", Registration, :register
    end
  end

  scope "/", Web.TenantPages do
    pipe_through [:browser]
  end

  # Redirects

  scope "/", Web do
    get "/login", Redirect, to: "/login/identifier"
  end

  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
