# credo:disable-for-this-file Credo.Check.Refactor.ModuleDependencies

defmodule MRP.Application do
  @moduledoc false

  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      Web.Telemetry,
      MRP.Repo,
      {Oban, oban_config()},
      {Phoenix.PubSub, name: MRP.PubSub},
      Web.Presence,
      Web.Endpoint
    ]

    opts = [strategy: :one_for_one, name: MRP.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp oban_config, do: Application.fetch_env!(:mrp, Oban)

  @impl Application
  def config_change(changed, _new, removed) do
    Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
