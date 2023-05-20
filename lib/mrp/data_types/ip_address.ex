defmodule MRP.DataTypes.IPAddress do
  @moduledoc """
  IP Address data type for Ecto.
  """

  use Ecto.Type

  @impl Ecto.Type
  def type, do: :inet

  @impl Ecto.Type
  def cast(string) when is_binary(string) do
    parts = String.split(string, ".")

    case Enum.map(parts, &Integer.parse/1) do
      [{a, ""}, {b, ""}, {c, ""}, {d, ""}]
      when a in 0..255
        and b in 0..255
        and c in 0..255
        and d in 0..255 ->
        {:ok, {a, b, c, d}}

      _data ->
        :error
    end
  end

  def cast(_data), do: :error

  @impl Ecto.Type
  def dump({_a, _b, _c, _d} = address), do: {:ok, %Postgrex.INET{address: address}}
  def dump(_data), do: :error

  @impl Ecto.Type
  def load(%Postgrex.INET{} = struct), do: {:ok, struct.address}
  def load(_data), do: :error
end
