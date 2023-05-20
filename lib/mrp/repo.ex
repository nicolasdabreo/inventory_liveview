defmodule MRP.Repo do
  use Ecto.Repo,
    otp_app: :mrp,
    adapter: Ecto.Adapters.Postgres
end
