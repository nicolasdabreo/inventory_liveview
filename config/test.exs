import Config

config :mrp, MRP.Repo,
  stacktrace: true,
  username: "postgres",
  password: "postgres",
  database: "mrp_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  ownership_timeout: 10 * 60 * 1000

config :mrp, Oban, testing: :inline

config :mrp, Web.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "TFBlLoK0gx0EeXf5TZJI+aZgjPYSCAaslBo1njGiKZoEJ/uooKoK2A2fPgP2alCq",
  server: false

config :mrp, Mailer.Email, adapter: Swoosh.Adapters.Test

config :bcrypt_elixir, :log_rounds, 1

config :logger, level: :warning

config :phoenix, :plug_init_mode, :runtime
