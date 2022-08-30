defmodule <%= @web_namespace %>.Components do
  @moduledoc """
  Provides core UI components.

  *Note*: The `modal`, `flash`, `table`, `button`, `hero`, `simple_form`, and `input`
  function components are derived from Tailwind UI, with explicit permission
  granted to the `phx.new` generator. Visit [Tailwind UI](https://tailwindui.com)
  for comprehensive components, or the [Tailwind CSS documentation](https://tailwindcss.com)
  to learn how to customize the generated components in this module.
  """
  use Phoenix.Component

  <%= if @gettext do %>import <%= @web_namespace %>.Gettext, warn: false
  <% end %>
  alias Phoenix.LiveView.JS

  @doc """
  Renders a modal.

  ## Examples

      <.modal id="confirm-modal">
        Are you sure you?
        <:confirm>OK</:confirm>
        <:cancel>Cancel</:confirm>
      <.modal>

  JS commands may be passed to the `:on_cancel` and `on_confirm` attributes
  for the caller to reactor to each button press, for example:

      <.modal id="confirm-modal" on_confirm={JS.push("delete-item")}>
        Are you sure you?
        <:confirm>OK</:confirm>
        <:cancel>Cancel</:confirm>
      <.modal>
  """

  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  attr :on_confirm, JS, default: %JS{}
  attr :rest, :global

  slot :inner_block, required: true
  slot :title
  slot :subtitle

  slot :confirm do
    attr :if, :boolean
  end

  slot :cancel do
    attr :if, :boolean
  end

  def modal(assigns) do
    ~H"""
    <div id={@id} phx-mounted={@show && show_modal(@id)} class="relative z-50 hidden" {@rest}>
      <div
        id={"#{@id}-backdrop"}
        class="fixed inset-0 bg-zinc-50/90 transition-opacity"
        aria-hidden="true"
      >
      </div>
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex min-h-full items-center justify-center">
          <div class="w-full max-w-3xl p-4 sm:p-6 lg:py-8">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-mounted={@show && show_modal(@id)}
              phx-window-keydown={hide_modal(@on_cancel, @id)}
              phx-key="escape"
              phx-click-away={hide_modal(@on_cancel, @id)}
              class="hidden relative rounded-2xl bg-white p-6 shadow-lg shadow-zinc-700/10 ring-1 ring-zinc-700/10 transition"
            >
              <div class="absolute top-6 right-6">
                <button
                  type="button"
                  phx-click={hide_modal(@on_cancel, @id)}
                  class="group -m-3 flex-none p-3"
                  aria-label="Close"
                >
                  <svg
                    viewBox="0 0 12 12"
                    aria-hidden="true"
                    class="h-3 w-3 stroke-zinc-300 group-hover:stroke-zinc-400"
                  >
                    <path d="M1 1L11 11M11 1L1 11" stroke-width="2" stroke-linecap="round" />
                  </svg>
                </button>
              </div>
              <div id={"#{@id}-content"}>
                <%%= if @title != [] do %>
                  <header>
                    <h1 id={"#{@id}-title"} class="text-lg font-semibold leading-8 text-zinc-800">
                      <%%= render_slot(@title) %>
                    </h1>
                    <%%= if @subtitle != [] do %>
                      <p class="mt-2 text-sm leading-6 text-zinc-600">
                        <%%= render_slot(@subtitle) %>
                      </p>
                    <%% end %>
                  </header>
                <%% end %>
                <%%= render_slot(@inner_block) %>
                <%%= if @confirm != [] or @cancel != [] do %>
                  <div class="ml-6 mb-4 flex items-center gap-5">
                    <%%= for confirm <- @confirm, Map.get(confirm, :if, true) do %>
                      <.button
                        id={"#{@id}-confirm"}
                        class="rounded-lg bg-zinc-900 py-2 px-3 text-sm font-semibold leading-6 text-white hover:bg-zinc-700 active:text-white/80"
                        phx-click={@on_confirm}
                        phx-disable-with
                      >
                        <%%= render_slot(confirm) %>
                      </.button>
                    <%% end %>
                    <%%= for cancel <- @cancel, Map.get(cancel, :if, true) do %>
                      <.link
                        class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
                        phx-click={hide_modal(@on_cancel, @id)}
                      >
                        <%%= render_slot(cancel) %>
                      </.link>
                    <%% end %>
                  </div>
                <%% end %>
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash}/>
      <.flash kind={:error} flash={get_flash(@conn)}/>
  """
  attr :flash, :map
  attr :kind, :atom, doc: "one of :info, :error"
  attr :animate, :boolean, default: true, doc: "animates in the flash"

  def flash(%{kind: :error} = assigns) do
    ~H"""
    <%%= if @flash[to_string(@kind)] do %>
      <div
        id="flash"
        class={"#{@animate && "hidden"} rounded-md bg-red-50 p-4 fixed top-1 right-1 w-96 z-50 shadow shadow-red-200"}
        phx-mounted={show("#flash")}
        phx-click={JS.push("lv:clear-flash") |> hide("#flash")}
      >
        <div class="flex justify-between items-center space-x-3 pl-2 text-red-700">
          <p class="flex-1 text-sm font-medium" role="alert">
            <%%= @flash[to_string(@kind)] %>
          </p>
          <button
            type="button"
            class="inline-flex bg-red-50 rounded-md p-1.5 text-red-500 hover:bg-red-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-red-50 focus:ring-red-600"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-6 w-6"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              stroke-width="2"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
          </button>
        </div>
      </div>
    <%% end %>
    """
  end

  def flash(%{kind: :info} = assigns) do
    ~H"""
    <%%= if @flash[to_string(@kind)] do %>
      <div
        id="flash"
        class={"#{@animate && "hidden"} rounded-md bg-green-50 p-4 fixed top-2 right-2 w-96 z-50 shadow shadow-green-200"}
        phx-mounted={show("#flash")}
        phx-click={JS.push("lv:clear-flash") |> hide("#flash")}
        phx-value-key="info"
      >
        <div class="flex justify-between items-center space-x-3 text-green-700 pl-2">
          <p class="flex-1 text-sm font-medium" role="alert">
            <%%= @flash[to_string(@kind)] %>
          </p>
          <button
            type="button"
            class="inline-flex bg-green-50 rounded-md p-1.5 text-green-600 hover:bg-green-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-green-50 focus:ring-green-600"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-6 w-6"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              stroke-width="2"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
          </button>
        </div>
      </div>
    <%% end %>
    """
  end

  @doc """
  Renders a simple form.

  ## Examples

      <.simple_form :let={f} for={:user} phx-change="validate" phx-submit="save">
        <:title>Profile</:title>
        <:subtitle>This information will be displayed publicly.</:subtitle>

        <.input field={{f, :email}} label="Email"/>
        <.input field={{f, :username}} label="Username" />

        <:confirm>Save</:confirm>
        <:cancel>Cancel</:cancel>
      </.simple_form>
  """

  slot :inner_block, required: true
  slot :title
  slot :subtitle

  slot :confirm do
    attr :if, :boolean
  end

  slot :cancel do
    attr :if, :boolean
  end

  attr :for, :any, default: nil
  attr :rest, :global

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} {@rest}>
      <div class="overflow-hidden">
        <div class="px-4 py-5 bg-white sm:p-6 grid grid-cols-4 gap-y-4">
          <%%= if @title || @subtitle do %>
            <div class="col-span-full mb-3">
              <%%= if @title do %>
                <h3 class="text-lg leading-6 font-medium text-gray-900">
                  <%%= render_slot(@title) %>
                </h3>
              <%% end %>
              <%%= if @subtitle do %>
                <p class="mt-1 text-sm text-gray-500"><%%= render_slot(@subtitle) %></p>
              <%% end %>
            </div>
          <%% end %>

          <%%= render_slot(@inner_block, f) %>

          <div class="mt-2 flex justify-end col-span-full">
            <%%= for cancel <- @cancel, Map.get(cancel, :if, true) do %>
              <.button type="button"><%%= render_slot(cancel) %></.button>
            <%% end %>
            <%%= for confirm <- @confirm, Map.get(confirm, :if, true) do %>
              <.button type="submit" class="ml-3"><%%= render_slot(confirm) %></.button>
            <%% end %>
          </div>
        </div>
      </div>
    </.form>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button class="abc">Send!</.button>
  """

  slot :inner_block, required: true
  attr :type, :string, default: "button"
  attr :class, :string, default: nil
  attr :rest, :global

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={
        [
          "phx-submit-loading:opacity-75 rounded-lg bg-zinc-900 py-2 px-3 text-sm font-semibold leading-6 text-white hover:bg-zinc-700 active:text-white/80",
          @class
        ]
      }
      {@rest}
    >
      <%%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  Renders an input with label and error messages.

  A `%Phoenix.HTML.Form{}` and field name may be passed to the input
  to build input names and error messages, or all the attributes and
  errors may be passed explicitly.

  ## Examples

      <.input field={{f, :email}} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  slot :inner_block
  attr :id, :any
  attr :name, :any
  attr :label, :string, default: nil

  attr :type, :string,
    default: "text",
    doc: ~s|one of "text", "number" "email", "date", "time", "datetime", "select"|

  attr :value, :any
  attr :field, :any, doc: "a %Phoenix.HTML.Form{}/field name tuple, for example: {f, :email}"
  attr :errors, :list
  attr :class, :string, default: nil
  attr :rest, :global

  def input(%{field: {f, field}} = assigns) do
    assigns
    |> assign(:field, nil)
    |> assign_new(:name, fn -> Phoenix.HTML.Form.input_name(f, field) end)
    |> assign_new(:id, fn -> Phoenix.HTML.Form.input_id(f, field) end)
    |> assign_new(:value, fn -> Phoenix.HTML.Form.input_value(f, field) end)
    |> assign_new(:errors, fn ->
      Enum.map(Keyword.get_values(f.errors, field), &translate_error(&1))
    end)
    |> input()
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div class={["col-span-full", @class]}>
      <label for={@id} class="block text-sm font-medium text-gray-700">
        <%%= @label %>
      </label>
      <select
        id={@id}
        name={@name}
        autocomplete={@name}
        class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
        {@rest}
      >
        <%%= for opt <- @option do %>
          <option {assigns_to_attributes(opt)}><%%= render_slot(opt) %></option>
        <%% end %>
      </select>
      <%%= for error <- @errors do %>
        <.error message={error} class="phx-no-feedback:hidden" phx-feedback-for={@name} />
      <%% end %>
    </div>
    """
  end

  def input(assigns) do
    ~H"""
    <div class={["col-span-full", @class]} phx-feedback-for={@name}>
      <label for={@id} class="block text-sm font-medium text-gray-700">
        <%%= @label %>
      </label>
      <input
        type={@type}
        name={@name}
        id={@id || @name}
        value={@value}
        class={"#{input_border(@errors)} phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 phx-no-feedback:focus:ring-zinc-800/5 mt-2 block w-full rounded-lg border-zinc-300 py-[calc(theme(spacing.2)-1px)] px-[calc(theme(spacing.3)-1px)] text-zinc-900 focus:outline-none focus:ring-4 sm:text-sm sm:leading-6"}
        {@rest}
      />
      <%%= for error <- @errors do %>
        <.error message={error} class="phx-no-feedback:hidden" />
      <%% end %>
    </div>
    """
  end

  defp input_border([] = _errors),
    do: "border-zinc-300 focus:border-zinc-400 focus:ring-zinc-800/5"

  defp input_border([_ | _] = _errors),
    do: "border-rose-400 focus:border-rose-400 focus:ring-rose-400/10"

  @doc """
  Generates a generic error message.
  """
  attr :message, :string, required: true
  attr :class, :string, default: nil
  attr :rest, :global

  def error(assigns) do
    ~H"""
    <p class={["mt-3 flex gap-3 text-sm leading-6 text-rose-600", @class]} {@rest}>
      <svg viewBox="0 0 20 20" aria-hidden="true" class="mt-0.5 h-5 w-5 flex-none fill-rose-500">
        <path fill-rule="evenodd" clip-rule="evenodd" d="M18 10a8 8 0 1 1-16.001 0A8 8 0 0 1 18 10Zm-7 4a1 1 0 1 1-2 0 1 1 0 0 1 2 0Zm-1-9a1 1 0 0 0-1 1v4a1 1 0 1 0 2 0V6a1 1 0 0 0-1-1Z"></path>
      </svg>
      <%%= @message %>
    </p>
    """
  end


  @doc """
  Renders containers only for screen readers.
  """

  slot :inner_block, required: true

  def screen_reader(assigns) do
    ~H"""
    <div class="sr-only"><%%= render_slot(@inner_block) %></div>
    """
  end

  @doc """
  Renders a header with title.
  """

  slot :title, required: true
  slot :subtitle
  slot :inner_block
  attr :class, :string, default: nil

  def header(assigns) do
    ~H"""
    <header class={["flex items-center justify-between gap-6", @class]}>
      <div>
        <h1 class="text-lg font-semibold leading-8 text-zinc-800"><%%= render_slot(@title) %></h1>
        <%%= if @subtitle != [] do %>
          <p class="mt-2 text-sm leading-6 text-zinc-600"><%%= render_slot(@subtitle) %></p>
        <%% end %>
      </div>
      <div class="flex-none">
        <%%= render_slot(@inner_block) %>
      </div>
    </header>
    """
  end

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table rows={@users} row_id={&"user-#{&1.id}"}>
        <:title>Users</:title>
        <:subtitle>Active in the last 24 hours</:subtitle>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.table>
  """

  attr :id, :string, required: true
  attr :row_click, JS, default: nil
  attr :rest, :global
  attr :bordered, :boolean, default: false
  attr :rows, :list, required: true
  attr :class, :string, default: nil

  slot :col, required: true
  slot :action

  def table(assigns) do
    ~H"""
    <div id={@id} class="overflow-y-auto px-4 sm:overflow-visible sm:px-0">
      <table class="mt-11 w-[40rem] sm:w-full">
        <thead class="text-left text-[0.8125rem] leading-6 text-zinc-500">
          <tr>
            <%%= for col <- @col do %>
              <th class="p-0 pb-4 pr-6 font-normal"><%%= col.label %></th>
            <%% end %>
            <th class="relative p-0 pb-4"><span class="sr-only">Actions</span></th>
          </tr>
        </thead>
        <tbody class="relative divide-y divide-zinc-100 border-t border-zinc-200 text-sm leading-6 text-zinc-700">
          <%%= for row <- @rows, row_id = "#{@id}-row-#{Phoenix.Param.to_param(row)}" do %>
            <tr id={row_id} class="group hover:bg-zinc-50  hover:cursor-pointer" phx-click={@row_click && @row_click.(row)}>
              <%%= for {col, i} <- Enum.with_index(@col) do %>
                <td class={["relative p-0", col[:class]]}>
                  <div class="block py-4 pr-6">
                    <span class="absolute -inset-y-px right-0 -left-4 group-hover:bg-zinc-50 sm:rounded-l-xl"></span>
                    <span class={["relative", if(i == 0, do: "font-semibold text-zinc-900")]}>
                      <%%= render_slot(col, row) %>
                    </span>
                  </div>
                </td>
              <%% end %>
              <%%= if @action !=[] do %>
                <td class="relative p-0">
                  <div class="relative whitespace-nowrap py-4 text-right text-sm font-medium">
                    <span class="absolute -inset-y-px -right-4 left-0 group-hover:bg-zinc-50 sm:rounded-r-xl"></span>
                    <%%= for action <- @action do %>
                      <span class="relative ml-4 font-semibold leading-6 text-zinc-900 hover:text-zinc-700">
                        <%%= render_slot(action, row) %>
                      </span>
                    <%% end %>
                  </div>
                </td>
              <%% end %>
            </tr>
          <%% end %>
        </tbody>
      </table>
    </div>
    """
  end

  @doc """
  TODO
  """

  slot :title
  slot :subtitle
  slot :header
  slot :item
  slot :nav

  def list(assigns) do
    ~H"""
    <%%= if @nav != [] do %>
      <div class="mb-8 sm:hidden">
        <%%= render_slot(@nav) %>
      </div>
    <%% end %>
    <header class="flex items-center justify-between gap-6">
      <div>
        <h1 class="text-lg font-semibold leading-8 text-zinc-800"><%%= render_slot(@title) %></h1>
        <p class="mt-2 text-sm leading-6 text-zinc-600"><%%= render_slot(@subtitle) %></p>
      </div>
      <div class="flex-none"><%%= render_slot(@header) %></div>
    </header>
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <%%= for item <- @item do %>
          <div class="flex gap-4 py-4 sm:gap-8">
            <dt class="w-1/4 flex-none text-[0.8125rem] leading-6 text-zinc-500"><%%= item.title %></dt>
            <dd class="text-sm leading-6 text-zinc-700"><%%= render_slot(item) %></dd>
          </div>
        <%% end %>
      </dl>
    </div>
    <%%= if @nav != [] do %>
      <div class="mt-16 hidden sm:block">
        <%%= render_slot(@nav) %>
      </div>
    <%% end %>
    """
  end

  @doc """
  Renders a back navigation link.
  """

  attr :navigate, :any, required: true
  slot :inner_block, required: true

  def back(assigns) do
    ~H"""
    <div class="mt-16">
      <.link navigate={@navigate} class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700">
        <span aria-hidden="true">&larr;</span>
        <%%= render_slot(@inner_block) %>
      </.link>
    </div>
    """
  end

  @doc """
  TODO
  """
  attr :id, :any, required: true
  slot :toggle
  slot :link, required: true

  def dropdown(assigns) do
    ~H"""
    <button
      phx-click={show_dropdown(@id)}
      aria-haspopup="true"
      aria-label="Actions"
      class="pointer-events-auto ml-auto flex items-center justify-center rounded-md hover:bg-zinc-700/5"
    >
      <%%= if @toggle == [] do %>
        <svg viewBox="0 0 24 24" aria-hidden="true" class="h-6 w-6 fill-zinc-600">
          <circle cx="8" cy="12" r="1" />
          <circle cx="12" cy="12" r="1" />
          <circle cx="16" cy="12" r="1" />
        </svg>
      <%% else %>
        <%%= render_slot(@toggle) %>
      <%% end %>
    </button>
    <div
      id={@id}
      phx-click-away={hide_dropdown(@id)}
      role="menu"
      aria-labelledby={@id}
      class="hidden pointer-events-auto absolute right-0 top-full z-10 mt-2 w-28 origin-top-right rounded-lg shadow-md shadow-zinc-900/5 ring-1 ring-zinc-700/10 transition"
    >
      <%%= for {link, i} <- Enum.with_index(@link), count = length(@link) do %>
        <.link
          class={[i == 0 && "rounded-t-lg", i == count - 1 && "rounded-b-lg", "block bg-white py-1.5 px-3 text-sm leading-6 text-zinc-900 hover:bg-zinc-50 hover:text-zinc-700"]}
          {assigns_to_attributes(link)}
        >
          <%%= render_slot(link) %>
        </.link>
      <%% end %>
    </div>
    """
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      time: 300,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 scale-95",
         "opacity-100 translate-y-0 scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 300,
      transition:
        {"transition-all transform ease-in duration-300", "opacity-100 scale-100",
         "opacity-0 scale-95"}
    )
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.push_focus()
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-backdrop",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> JS.show(
      to: "##{id}-container",
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-backdrop",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> JS.hide(
      to: "##{id}-container",
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.pop_focus()
  end

  def show_dropdown(id) do
    JS.show(
      to: "##{id}",
      transition:
        {"transition ease-out duration-100", "transform opacity-0 scale-95",
         "transform opacity-100 scale-100"}
    )
    |> JS.set_attribute({"aria-expanded", "true"}, to: "##{id}")
  end

  def hide_dropdown(id) do
    JS.hide(
      to: "##{id}",
      transition:
        {"transition ease-in duration-75", "transform opacity-100 scale-100",
         "transform opacity-0 scale-95"}
    )
    |> JS.remove_attribute("aria-expanded", to: "##{id}")
  end<%= if @gettext do %>

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(<%= @web_namespace %>.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(<%= @web_namespace %>.Gettext, "errors", msg, opts)
    end
  end<% else %>

  @doc """
  Translates an error message.
  """
  def translate_error({msg, opts}) do
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end<% end %>
end
