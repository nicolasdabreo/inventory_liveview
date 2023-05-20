defmodule MRP.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Web.Telemetry,
      MRP.Repo,
      {Oban, oban_config()},
      {Phoenix.PubSub, name: MRP.PubSub},
      Web.Endpoint
    ]

    opts = [strategy: :one_for_one, name: MRP.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp oban_config, do: Application.fetch_env!(:mrp, Oban)

  @impl true
  def config_change(changed, _new, removed) do
    Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
