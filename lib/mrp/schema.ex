defmodule Store.Schema do
  @moduledoc """
  Helper module for Ecto schemas, uses UUID by default for the
  foreign key.
  """

  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      import Ecto.Changeset

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      @timestamps_opts [type: :utc_datetime]
    end
  end
end
