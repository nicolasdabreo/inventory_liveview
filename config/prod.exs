import Config

config :mrp, Web.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  url: [scheme: "https"],
  http: [
    ip: {0, 0, 0, 0, 0, 0, 0, 0}
  ]

config :mrp, Mailer.Email, adapter: Swoosh.Adapters.Mailgun

config :swoosh,
  api_client: Swoosh.ApiClient.Finch,
  local: false
