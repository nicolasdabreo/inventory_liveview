defmodule Mailer.HTML do
  @moduledoc """
  View module for rendering email templates and defining templating helpers.
  """

  use Phoenix.Component

  import Swoosh.Email

  embed_templates "./*"

  def base_email_from_support(to) do
    new()
    |> to(to)
    |> from({"MRP", support_email()})
  end

  def base_email_from_noreply(to) do
    new()
    |> to(to)
    |> from({"MRP", noreply_email()})
  end

  defp support_email, do: Application.get_env(:mrp, :support_email)
  defp noreply_email, do: Application.get_env(:mrp, :noreply_email)

  def render_with_layout(email, heex) do
    html_body(
      email,
      render_component(__MODULE__.layout(%{email: email, inner_content: heex}))
    )
  end

  def render_with_layout(email, inner_function, assigns) do
    heex = apply(__MODULE__, inner_function, [assigns])

    html_body(
      email,
      render_component(__MODULE__.layout(%{email: email, inner_content: heex}))
    )
  end

  defp render_component(heex) do
    heex |> encode_to_iodata!() |> IO.chardata_to_string()
  end

  def encode_to_iodata!(mjml) do
    with {:ok, html} <- Mjml.to_html(mjml) do
      html
    end
  end
end
