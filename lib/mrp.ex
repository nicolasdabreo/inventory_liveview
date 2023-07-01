# credo:disable-for-this-file Credo.Check.Refactor.ModuleDependencie

defmodule MRP do
  @moduledoc """
  MRP keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def schema do
    quote do
      use Ecto.Schema

      import Ecto.Changeset
      import Ecto.Query

      @primary_key {:id, Ecto.UUID, autogenerate: true}
      @foreign_key_type :binary_id
      @timestamps_opts [type: :utc_datetime]
    end
  end

  def domain do
    quote do
      import Ecto.Query, warn: false

      alias Ecto.Multi
      alias MRP.Repo
      alias Mailer.Emails
    end
  end

  @doc """
  When used, dispatch to the appropriate underlying functions.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
