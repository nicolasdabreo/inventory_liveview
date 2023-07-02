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
attr :row_id, :any, default: nil, doc: "the function for generating the row id"
attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

attr :row_item, :any,
  default: &Function.identity/1,
  doc: "the function for mapping each row before calling the :col and :action slots"

slot :col, required: true do
  attr :label, :string
end

slot :action, doc: "the slot for showing user actions in the last table column"

def table(assigns) do
  assigns =
    with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
      assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
    end

~H"""
  <div class={["overflow-y-auto sm:overflow-visible", @class]}>
    <table class="w-[40rem] sm:w-full">
      <thead class="text-left text-[0.8125rem] leading-6 text-zinc-300">
        <tr>
          <th class="w-1/12" />
          <th :for={col <- @col} class="p-0 pb-4 pr-6 font-normal"><%= col[:label] %></th>
          <th class="relative p-0 pb-4"><span class="sr-only"><%= gettext("Actions") %></span></th>
          <th class="w-1/12" />
        </tr>
      </thead>
      <tbody
        id={@id}
        phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
        class="relative text-sm leading-6 border-t divide-y divide-zinc-700 border-zinc-500 text-zinc-300"
      >
        <tr :for={row <- @rows} id={@row_id && @row_id.(row)} class="group hover:bg-zinc-700">
        <td />
          <td
            :for={{col, i} <- Enum.with_index(@col)}
            phx-click={@row_click && @row_click.(row)}
            class={["relative p-0", @row_click && "hover:cursor-pointer"]}
          >
            <div class="block py-4 pr-6">
              <span class="absolute right-0 -inset-y-px -left-4 sm:rounded-l-xl" />
              <span class={["relative", i == 0 && "font-semibold text-zinc-300"]}>
                <%= render_slot(col, @row_item.(row)) %>
              </span>
            </div>
          </td>
          <td :if={@action != []} class="relative p-0 w-14">
            <div class="relative py-4 text-sm font-medium text-right whitespace-nowrap">
              <span class="absolute left-0 -inset-y-px -right-4 sm:rounded-r-xl" />
              <span
                :for={action <- @action}
                class="relative ml-4 font-semibold leading-6 text-zinc-200 hover:text-zinc-300"
              >
                <%= render_slot(action, @row_item.(row)) %>
              </span>
            </div>
          </td>
        <td />
        </tr>
      </tbody>
    </table>
  </div>
  """
end


  defp tbody(%{rows: rows} = assigns) do
    ~H"""
    <tbody
      id={@id}
      phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
      class="divide-y divide-white/5"
    >
      <%= render_slot(@inner_block, @rows) %>
    </tbody>
    """
  end

  defp whole_group_selected?(rows, selected_rows) do
    Enum.all?(rows, &(&1.id in selected_rows))
  end

  defp table_row(assigns) do
    ~H"""
    <tr
      id={"#{@id}-#{@row.id}"}
      class={[
        "group focus:ring-inset",
        @row_click && "hover:cursor-pointer"
      ]}
      tabindex={if @row_click, do: "0", else: "-1"}
    >
      <td :if={@selected_rows} scope="col" class="p-0">
        <div
          class={["px-4 py-1 text-right whitespace-nowrap", @row_click && "hover:cursor-pointer"]}
          phx-click={@row_click && @row_click.(@row)}
        >
          <input
            type="checkbox"
            class="flex flex-shrink-0 w-4 h-4 accent-violet-500"
            checked={@row.id in @selected_rows}
          />
        </div>
      </td>
      <td
        :for={{col, _i} <- Enum.with_index(@col)}
        phx-click={@row_click && @row_click.(@row)}
        class={["py-1", @row_click && "hover:cursor-pointer", col[:class]]}
      >
        <div class="block py-1">
          <span class="relative">
            <%= render_slot(col, @row) %>
          </span>
        </div>
      </td>
      <td :if={@action != []} class="relative p-0 ">
        <div class="py-1 text-right whitespace-nowrap">
          <span :for={action <- @action} class="flex flex-row items-center gap-3 leading-6">
            <%= render_slot(action, @row) %>
          </span>
        </div>
      </td>
    </tr>
    """
  end

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
        <div :for={item <- @item} class="flex gap-4 py-4 text-sm leading-6 sm:gap-8">
          <dt class="flex-none w-1/4 text-zinc-500"><%= item.title %></dt>
          <dd class="text-zinc-700"><%= render_slot(item) %></dd>
        </div>
      </dl>
    </div>
    """
  end
end
