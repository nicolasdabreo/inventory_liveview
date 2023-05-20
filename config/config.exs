import Config

config :mrp,
  ecto_repos: [MRP.Repo],
  generators: [binary_id: true],
  migration_timestamps: [type: :utc_datetime],
  support_email: "help@mrp.com",
  noreply_email: "noreply@mrp.com"

config :mrp, Oban,
  repo: MRP.Repo,
  queues: [default: 1, mailer: 1],
  plugins: [
    Oban.Plugins.Gossip,
    Oban.Plugins.Pruner,
    {Oban.Plugins.Cron, crontab: []}
  ]

config :mrp, Mailer.Email, adapter: Swoosh.Adapters.Local

config :mrp, Web.Endpoint,
  url: [host: "localhost"],
  render_errors: [formats: [html: Web.Pages.ErrorHTML], layout: false],
  pubsub_server: MRP.PubSub,
  live_view: [signing_salt: "Z3i1EZ84"]

#
# Other
#

config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.2.7",
  default: [
    args: ~w(
    --config=tailwind.config.js
    --input=css/app.css
    --output=../priv/static/assets/app.css
  ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :swoosh, :api_client, false

import_config "#{config_env()}.exs"
