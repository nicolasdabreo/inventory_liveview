defmodule MRP.Accounts.Identity do
  use MRP, :schema

  @derive {Inspect, except: [:token]}
  schema "credentials" do
    field :token, :string, source: :value
    field :type, Ecto.Enum, values: [:google]
    belongs_to :user, MRP.Accounts.User

    timestamps()
  end
end
