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

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :label, :string
    attr :class, :string
    attr :data_label, :string
    attr :align, :atom
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <table role="table" class={["overflow-x-auto w-full table-fixed", @class]}>
      <thead role="rowgroup" class="sticky text-left text-[0.8125rem] text-zinc-300 bg-zinc-800 pt-4">
        <tr role="row">
          <th class="sticky top-0 z-10 hidden w-8 sm:table-cell" role="columnheader" />
          <th
            :for={col <- @col}
            role="columnheader"
            class={[
              "sticky top-0 z-10 hidden sm:table-cell py-2 px-2 font-normal",
              col[:class],
              text_align_classes(col[:align])
            ]}
          >
            <%= col[:label] %>
          </th>
          <th class="relative sticky top-0 z-10 hidden w-24 py-2 sm:table-cell" role="columnheader">
            <span class="sr-only"><%= gettext("Actions") %></span>
          </th>
          <th class="sticky top-0 z-10 hidden w-8 sm:table-cell" role="columnheader" />
        </tr>
      </thead>
      <tbody
        id={@id}
        role="rowgroup"
        phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
        class="relative text-sm border-t divide-y divide-zinc-800 border-zinc-800 text-zinc-300"
      >
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
                  "pl-4 py-1 text-right whitespace-nowrap opacity-0 group-hover:opacity-100 peer",
                  @row_click && "group-hover:cursor-pointer"
                ]}
                phx-click={@row_click && @row_click.(row)}
              >
                <input type="checkbox" class="flex flex-shrink-0 w-4 h-4" />
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
              <span class="absolute right-0 -inset-y-px -left-4 sm:rounded-l-xl" />
              <span class={[
                "relative inline-block w-28 sm:w-auto",
                i == 0 && "font-semibold text-zinc-300"
              ]}>
                <%= render_slot(col, @row_item.(row)) %>
              </span>
            </div>
          </td>
          <td class="hidden w-24 sm:table-cell" role="cell" class="relative px-3">
            <div class="relative py-4 text-sm font-medium text-right whitespace-nowrap">
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
        <div :for={item <- @item} class="flex gap-4 py-4 text-sm sm:gap-8">
          <dt class="flex-none w-1/4 text-zinc-500"><%= item.title %></dt>
          <dd class="text-zinc-700"><%= render_slot(item) %></dd>
        </div>
      </dl>
    </div>
    """
  end
end
