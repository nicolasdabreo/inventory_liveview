defmodule MRP.Organisations do
  use MRP, :context

  alias MRP.Organisations.Organisation

  def list_organisations, do: Repo.all(Organisation)
  def get_organisation!(name), do: Repo.get_by!(Organisation, name: name)

  def initialise_organisation(name, params) do
    Triplex.create_schema(name, Repo, fn tenant, repo ->
      {:ok, _result} = Triplex.migrate(tenant, repo)

      Repo.transaction(fn -> create_organisation(params) end)
    end)
  end

  defp create_organisation(%{"organisation" => params}) do
    params
    |> Organisation.create_changeset()
    |> Repo.insert()
    |> case do
      {:ok, organisation} -> {:ok, organisation}
      {:error, error} -> Repo.rollback(error)
    end
  end
end
