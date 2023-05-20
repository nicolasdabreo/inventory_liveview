import Config

if config_env() == :prod do
  maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

  config :mrp,
    basic_auth: [username: "hello", password: "secret"]

  config :mrp, MRP.Repo,
    ssl: ConfigHelpers.get_env("POSTGRES_SSL", false, :boolean),
    url: ConfigHelpers.get_env("POSTGRES_URL", :no_default),
    pool_size: ConfigHelpers.get_env("POSTGRES_POOL", 10, :integer),
    socket_options: maybe_ipv6

  if ConfigHelpers.get_env("PHX_SERVER", false, :boolean) do
    config :mrp, Web.Endpoint, server: true
  end

  port = ConfigHelpers.get_env("PORT", :no_default, :integer)
  host = ConfigHelpers.get_env("HOST", :no_default)

  config :mrp, Web.Endpoint,
    url: [host: host, port: port],
    http: [port: port]
end

if ConfigHelpers.get_env("GITLAB_CI", false, :boolean) do
  config :mrp, MRP.Repo, url: ConfigHelpers.get_env("POSTGRES_URL", :no_default)
end

config :mrp, Web.Endpoint,
  secret_key_base: ConfigHelpers.get_env("SECRET_KEY_BASE", :no_default)

logger_level =
  (config_env() == :test && :warn) || ConfigHelpers.get_env("LOG_LEVEL", :warn, :atom)

config :logger, :level, logger_level
