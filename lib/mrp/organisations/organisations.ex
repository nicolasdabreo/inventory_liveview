defmodule MRP.Organisations do
  use MRP, :context

  alias MRP.Organisations.Organisation

  def list_organisations, do: Repo.all(Organisation)
  def get_organisation!(name), do: Repo.get_by!(Organisation, name: name)

  def initialise_organisation(name, attrs) do
    Triplex.create_schema(name, Repo, fn tenant, repo ->
      {:ok, _result} = Triplex.migrate(tenant, repo)

      Repo.transaction(fn ->
        with {:ok, organisation} <- create_organisation(attrs["organisation"]) do
          {:ok, organisation}
        else
          {:error, error} ->
            Repo.rollback(error)
        end
      end)
    end)
  end

  defp create_organisation(attrs) do
    attrs
    |> Organisation.create_changeset()
    |> Repo.insert()
  end
end
