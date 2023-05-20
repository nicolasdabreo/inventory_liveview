defmodule ConfigHelpers do
  @moduledoc """
  Provides useful abstrations for working with Configuration files and
  Environment Variables.
  """

  @type config_type :: :string | :integer | :boolean | :json | :atom

  @doc """
  Get value from environment variable, converting it to the given type if
  needed.

  If no default value is given, or `:no_default` is given as the default, an
  error is raised if the variable is not set.
  """
  @spec get_env(String.t(), :no_default | any(), config_type()) :: any()
  def get_env(var, default \\ :no_default, type \\ :string)

  def get_env(var, :no_default, type) do
    var
    |> System.fetch_env!()
    |> get_with_type(type)
  end

  def get_env(var, default, type) do
    case System.fetch_env(var) do
      {:ok, val} ->
        get_with_type(val, type)

      :error ->
        default
    end
  end

  @spec get_with_type(String.t(), config_type()) :: any()
  defp get_with_type(val, type)

  defp get_with_type(val, :string), do: val
  defp get_with_type(val, :atom), do: String.to_existing_atom(val)
  defp get_with_type(val, :integer), do: String.to_integer(val)
  defp get_with_type("true", :boolean), do: true
  defp get_with_type("false", :boolean), do: false
  defp get_with_type(val, :json), do: Jason.decode!(val)
  defp get_with_type(val, type), do: raise("Cannot convert to #{inspect(type)}: #{inspect(val)}")
end
