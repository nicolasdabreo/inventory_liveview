defmodule Web.Components.Data do
  @moduledoc false

  use Phoenix.Component

  attr(:id, :string, required: true)
  attr(:rows, :list, default: [])
  attr(:selected_rows, :list, default: nil)
  attr(:class, :string, default: "")
  attr(:max_rows, :integer, default: 10)

  attr(:row_id, :any, default: nil, doc: "the function for generating the row id")
  attr(:row_click, :any, default: nil, doc: "the function for handling phx-click on each row")

  attr(:group_click, :any, default: nil, doc: "the function for handling phx-click on a row group")

  attr(:row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"
  )

  slot :col, required: true do
    attr(:label, :string)
    attr(:class, :string)
  end

  slot(:action, doc: "the slot for showing user actions in the last table column") do
    attr(:disabled, :boolean)
  end

  slot(:empty, doc: "the slot which shows when the rows are empty")

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div id={@id} class={["overflow-x-auto", @class]}>
      <table class="w-full text-left whitespace-nowrap">
        <colgroup>
          <col class="w-1" />
          <col class="lg:w-4/12" />
          <col class="lg:w-2/12" />
          <col class="lg:w-2/12" />
          <col class="lg:w-2/12" />
        </colgroup>

        <thead class="text-sm leading-6 text-white border-b border-white/10">
          <tr>
            <th :if={@selected_rows} />
            <th :for={col <- @col} class="py-2 font-semibold truncate">
              <%= col[:label] %>
            </th>
            <th class="relative p-0 pb-4"><span class="sr-only">Actions</span></th>
          </tr>
        </thead>

        <.tbody
          :let={rows}
          id={@id}
          rows={@rows}
          col={@col}
          action={@action}
          selected_rows={@selected_rows}
          group_click={@group_click}
        >
          <.table_row
            :for={{row, i} <- Enum.with_index(rows)}
            index={i}
            row={row}
            row_click={@row_click}
            id={@id}
            col={@col}
            selected_rows={@selected_rows}
            action={@action}
          />
        </.tbody>

        <tbody :if={Enum.empty?(@rows)} class="leading-6 border-b border-white/10">
          <tr>
            <td class="w-full p-8 mx-auto text-center" colspan={length(@col) + 1}>
              <%= render_slot(@empty) %>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  defp tbody(%{rows: row_group} = assigns) when is_map(row_group) do
    ~H"""
    <tbody
      :for={{group, rows} <- @rows}
      id={@id}
      phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
      class="divide-y divide-white/5"
    >
      <tr id={"#{@id}-group-#{group}"}>
        <td
          :if={@selected_rows}
          scope="col"
          class="py-1 text-right whitespace-nowrap bg-clip-padding"
          phx-click={@group_click && @group_click.(group)}
          phx-value-state={if whole_group_selected?(rows, @selected_rows), do: "off", else: "on"}
        >
          <input
            type="checkbox"
            class="flex flex-shrink-0 w-4 h-4 rounded-md accent-primary"
            checked={whole_group_selected?(rows, @selected_rows)}
          />
        </td>
        <td
          scope="colgroup"
          colspan={if Enum.empty?(@action), do: length(@col), else: length(@col) + 1}
          class="py-2 text-xs font-semibold text-left"
        >
          <%= String.upcase(group) %>
        </td>
      </tr>
      <div>
        <%= render_slot(@inner_block, rows) %>
      </div>
    </tbody>
    """
  end

  defp tbody(%{rows: rows} = assigns) when is_list(rows) do
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
        @row_click && "hover:cursor-pointer",
        @row.id in @selected_rows && "bg-zinc-800"
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
