# credo:disable-for-this-file Credo.Check.Refactor.ModuleDependencies
defmodule Web.Router do
  use Web, :router

  import Web.Authenticate

  alias Web.Authenticate
  alias Web.Assigns
  alias Web.Components.Layouts

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Cldr.Plug.AcceptLanguage, cldr_backend: Web.Cldr
    plug Web.Plugs.I18n
  end

  scope "/", Web.Pages do
    pipe_through [:browser]

    live_session :marketing, on_mount: [Authenticate, Assigns] do
      live "/", LandingLive
    end
  end

  scope "/", Web.Pages do
    pipe_through [:browser]

    live_session :dashboard, on_mount: [{Authenticate, :user}, Assigns] do
        live "/dashboard", DashboardLive, :dashboard
    end
  end

  scope "/", Web.Pages.AuthenticationLive do
    pipe_through [:browser]

    delete "/logout", SessionController, :delete
    post "/login", SessionController, :create

    live_session :verification, on_mount: [Authenticate] do
      live "/emails/verify/:token", Verification, :edit
      live "/emails/verify", VerificationInstructions, :new
    end

    pipe_through [:redirect_if_user_is_authenticated]

    live_session :authentication, on_mount: [Assigns], layout: {Layouts, :auth} do
      live "/login", Login, :login
      live "/register", Registration, :register
    end
  end

  scope "/", Web.TenantPages do
    pipe_through [:browser]
  end

  # Redirects

  scope "/", Web do
  end

  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
