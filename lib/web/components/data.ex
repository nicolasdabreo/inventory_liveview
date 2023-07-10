defmodule Web.Components.Data do
  @moduledoc false

  use Phoenix.Component

  import Web.Gettext

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>

   </.table>
  """
  attr :id, :string, required: true
  attr :class, :string, default: ""
  attr :rows, :list, required: true
  attr :selected_rows, :any, default: []
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"
  attr :row_class, :string, default: ""
  attr :sticky, :boolean, default: true

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :label, :string
    attr :class, :string
    attr :data_label, :string
    attr :align, :atom
  end

  slot :inner_block

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <table role="table" class={["w-full table-fixed", @class]}>
      <thead class={["text-left text-[0.8125rem] text-zinc-300 pt-4 bg-zinc-800", @sticky && "sticky top-14 z-10"]} role="rowgroup">
        <tr role="row">
          <th class="hidden w-8 sm:table-cell" role="columnheader" />
          <th
            :for={col <- @col}
            role="columnheader"
            class={[
              "hidden sm:table-cell py-2 px-2 font-normal",
              col[:class],
              text_align_classes(col[:align])
            ]}
          >
            <%= col[:label] %>
          </th>
          <th :if={@action != []} class="relative hidden w-24 py-2 sm:table-cell" role="columnheader">
            <span class="sr-only"><%= gettext("Actions") %></span>
          </th>
          <th class="hidden w-8 sm:table-cell" role="columnheader" />
        </tr>
      </thead>
      <tbody
        id={@id}
        role="rowgroup"
        phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
        class="relative border-t divide-y divide-zinc-800 border-zinc-800 text-zinc-300"
      >
        <%= render_slot(@inner_block) %>
        <tr
          :for={{dom_id, _} = row <- @rows}
          role="row"
          id={@row_id && @row_id.(row)}
          class={["group hover:bg-zinc-700", @row_class]}
        >
          <%= if dom_id in @selected_rows do %>
            <td class="relative hidden w-8 sm:table-cell" role="cell">
              <div class="absolute inset-y-0 left-0 w-1 bg-blue-500"></div>
              <div
                class={[
                  "pl-4 py-1 text-right whitespace-nowrap",
                  @row_click && "hover:cursor-pointer"
                ]}
                phx-click={@row_click && @row_click.(row)}
              >
                <input type="checkbox" class="flex flex-shrink-0 w-4 h-4" checked />
              </div>
            </td>
          <% else %>
            <td class="relative hidden w-8 sm:table-cell" role="cell">
              <div
                class={[
                  "pl-4 py-1 text-right whitespace-nowrap peer",
                  @row_click && "group-hover:cursor-pointer"
                ]}
                phx-click={@row_click && @row_click.(row)}
              >
                <input type="checkbox" name={"#{dom_id}-selected"} class="w-4 h-4 text-blue-600 rounded bg-zinc-100 border-zinc-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-zinc-800 focus:ring-2 dark:bg-zinc-700 dark:border-zinc-600">
              </div>
            </td>
          <% end %>
          <td
            :for={{col, i} <- Enum.with_index(@col)}
            phx-click={@row_click && @row_click.(row)}
            class={[
              "relative px-3 py-1",
              @row_click && "hover:cursor-pointer",
              col[:class],
              text_align_classes(col[:align])
            ]}
            tabindex={if @row_click, do: "0", else: "-1"}
          >
            <div class="block">
              <p :if={col[:data_label]} class="inline-block mr-2 font-semibold sm:hidden">
                <%= col[:data_label] %>:
              </p>
              <span class={[
                "relative inline-block w-28 sm:w-full",
                i == 0 && "font-semibold text-zinc-300"
              ]}>
                <%= render_slot(col, @row_item.(row)) %>
              </span>
            </div>
          </td>
          <td :if={@action != []} class="hidden w-24 sm:table-cell" role="cell" class="relative px-3">
            <div class="relative py-4 font-medium text-right whitespace-nowrap">
              <span class="absolute left-0 -inset-y-px -right-4 sm:rounded-r-xl" />
              <span
                :for={action <- @action}
                class="relative ml-4 font-semibold text-zinc-200 hover:text-zinc-300"
              >
                <%= render_slot(action, @row_item.(row)) %>
              </span>
            </div>
          </td>
          <td class="w-8" role="cell" class="relative px-3"></td>
        </tr>
      </tbody>
    </table>
    """
  end

  defp text_align_classes(:right), do: "text-right"
  defp text_align_classes(:center), do: "text-center"
  defp text_align_classes(_left), do: "text-left"

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title"><%= @post.title %></:item>
        <:item title="Views"><%= @post.views %></:item>
      </.list>
  """
  slot :item, required: true do
    attr(:title, :string, required: true)
  end

  def list(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <div :for={item <- @item} class="flex gap-4 py-4 sm:gap-8">
          <dt class="flex-none w-1/4 text-zinc-500"><%= item.title %></dt>
          <dd class="text-zinc-700"><%= render_slot(item) %></dd>
        </div>
      </dl>
    </div>
    """
  end
end
