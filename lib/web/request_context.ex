defmodule Web.RequestContext do
  @moduledoc """
  Data plug for assigning the context required for building
  AuditLogs.
  """

  alias Extensions.Ecto
  alias Store.AuditLog

  def put_audit_context(conn_or_socket, opts \\ [])

  def put_audit_context(%Plug.Conn{} = conn, _) do
    user_agent =
      case List.keyfind(conn.req_headers, "user-agent", 0) do
        {_, value} -> value
        _ -> nil
      end

    Plug.Conn.assign(conn, :audit_context, %AuditLog{
      user_agent: user_agent,
      ip_address: get_ip(conn.req_headers),
      user: conn.assigns[:current_user]
    })
  end

  def put_audit_context(%Phoenix.LiveView.Socket{} = socket, _) do
    audit_context = %AuditLog{user: socket.assigns[:current_user]}
    peer_data = Phoenix.LiveView.get_connect_info(socket, :peer_data)
    user_agent = Phoenix.LiveView.get_connect_info(socket, :user_agent)
    extra = %{ip_address: peer_data.address, user_agent: user_agent}
    Phoenix.Component.assign(socket, :audit_context, struct!(audit_context, extra))
  end

  defp get_ip(headers) do
    with {_, ip} <- List.keyfind(headers, "x-forwarded-for", 0),
         [ip | _] = String.split(ip, ","),
         {:ok, address} <- Ecto.IPAddress.cast(ip) do
      address
    else
      _ ->
        nil
    end
  end
end
