defmodule Web.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """

  use Phoenix.Presence,
    otp_app: :mrp,
    pubsub_server: MRP.PubSub

  def init(_opts), do: {:ok, %{}} # user land state

  # def handle_metas(topic, %{joins: joins, leaves: leaves}, _presences, state) do
  #   for {_user_id, presence} <- joins, do: broadcast_entity_update(topic, presence)
  #   for {_user_id, presence} <- leaves, do: broadcast_entity_update(topic, presence)

  #   {:ok, state}
  # end

  # defp broadcast_entity_update(topic, presence) do
  #   metas = List.first(presence.metas)
  #   LiveHelpers.broadcast(topic, :insert, metas.entity)
  # end

  # def track_live_entity(pid, topic, current_user, entity) do
  #   track(
  #     pid,
  #     topic,
  #     current_user.id,
  #     %{
  #       entity: entity,
  #       email: current_user.email,
  #       user_id: current_user.id
  #     }
  #   )
  # end

  # def update_live_entity(pid, topic, current_user, entity) do
  #   update(
  #     pid,
  #     topic,
  #     current_user.id,
  #     %{
  #       entity: entity,
  #       email: current_user.email,
  #       user_id: current_user.id
  #     }
  #   )
  # end

  # @doc """
  # Returns a map of used entities for a given topic with the email
  # and id of the user for each used entity in the list.
  # """
  # def filter_use_of_entities(topic) do
  #   enum = topic
  #   |> list()
  #   |> Enum.map(fn {_, v} ->
  #       v.metas |> Enum.into(%{}, fn m -> {m.entity.id, %{email: m.email, id: m.user_id}} end)
  #     end)

  #   if Enum.empty?(enum) do
  #     %{}
  #   else
  #     Enum.reduce(enum, &Map.merge/2)
  #   end
  # end

  # @doc """
  # Checks the `presence_map` for the `entity.id`
  # When found, it retuns a map with the user's `email`, and `id`.
  # It returns `false` otherwise.

  # ## Examples

  #     # The entity with id 10 is used by the user "admin"
  #     iex> is_entity_used(presence_map, 10)
  #     %{id: 1, email: "admin@admin"}

  #     # The entity with id 11 is not used by anyone
  #     iex> is_entity_used(presence_map, 11)
  #     false

  #     # Also works by passing the topic instead of the presence list
  #     iex> is_entity_used("some_topic", 10)
  #     %{id: 1, email: "admin@admin"}
  # """
  # def is_entity_used(topic, entity_id) when is_binary(topic) do
  #   topic |> filter_use_of_entities() |> is_entity_used(entity_id)
  # end

  # def is_entity_used(presence_map, entity_id) do
  #   entity_id = if is_binary(entity_id), do: String.to_integer(entity_id), else: entity_id

  #   case Map.get(presence_map, entity_id) do
  #     nil -> false
  #     user -> user
  #   end
  # end
end
