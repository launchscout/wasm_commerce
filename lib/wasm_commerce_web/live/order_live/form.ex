defmodule WasmCommerceWeb.OrderLive.Form do
  use WasmCommerceWeb, :live_view
  alias WasmCommerce.{Accounts, Catalog, Orders}
  require Logger

  def mount(_params, _session, socket) do
    customers = Accounts.list_customers()
    products = Catalog.list_products()

    {:ok, assign(socket,
      customers: customers,
      products: products,
      line_items: [],
      selected_customer: nil,
      selected_product: nil,
      quantity: 1
    )}
  end

  def handle_event("select_customer", %{"customer_id" => customer_id}, socket) do
    Logger.info("Selected customer: #{customer_id}")
    {:noreply, assign(socket, selected_customer: customer_id)}
  end

  def handle_event("select_product", %{"product_id" => product_id}, socket) do
    Logger.info("Selected product: #{product_id}")
    {:noreply, assign(socket, selected_product: product_id)}
  end

  def handle_event("update_quantity", %{"quantity" => quantity}, socket) do
    case Integer.parse(quantity) do
      {num, _} when num > 0 -> {:noreply, assign(socket, quantity: num)}
      _ -> {:noreply, assign(socket, quantity: 1)}
    end
  end

  def handle_event("add_line_item", _params, socket) do
    Logger.info("Adding line item. Selected product: #{inspect(socket.assigns.selected_product)}")
    %{selected_product: product_id, quantity: quantity, line_items: line_items} = socket.assigns

    if product_id && product_id != "" && quantity > 0 do
      product = Catalog.get_product!(product_id)
      Logger.info("Found product: #{inspect(product)}")

      new_line_item = %{
        product_id: product.id,
        product_name: product.name,
        quantity: quantity,
        unit_price: product.price,
        subtotal: Decimal.mult(product.price, Decimal.new(quantity))
      }

      {:noreply, assign(socket,
        line_items: [new_line_item | line_items],
        selected_product: nil,
        quantity: 1
      )}
    else
      {:noreply, put_flash(socket, :error, "Please select a product and enter a valid quantity")}
    end
  end

  def handle_event("create_order", _, socket) do
    %{selected_customer: customer_id, line_items: line_items} = socket.assigns

    if customer_id && length(line_items) > 0 do
      {:ok, order} = Orders.create_order(%{customer_id: customer_id})

      Enum.each(line_items, fn item ->
        Orders.create_line_item(%{
          order_id: order.id,
          product_id: item.product_id,
          quantity: item.quantity,
          unit_price: item.unit_price,
          subtotal: item.subtotal
        })
      end)

      Orders.calculate_order_total(order.id)

      {:noreply,
        socket
        |> put_flash(:info, "Order created successfully!")
        |> redirect(to: ~p"/orders/#{order.id}")}
    else
      {:noreply, put_flash(socket, :error, "Please select a customer and add at least one item")}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto p-4">
      <h1 class="text-2xl font-bold mb-4">Create New Order</h1>

      <.form for={%{}} phx-change="form_change" id="order-form">
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700">Customer</label>
          <select
            name="customer_id"
            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
            phx-change="select_customer"
          >
            <option value="">Select a customer</option>
            <%= for customer <- @customers do %>
              <option value={customer.id} selected={@selected_customer == "#{customer.id}"}><%= customer.name %></option>
            <% end %>
          </select>
        </div>
      </.form>

      <div class="mb-4">
        <label class="block text-sm font-medium text-gray-700">Add Items</label>
        <div class="flex gap-4">
          <form phx-change="select_product" id="product-form">
            <select
              name="product_id"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
            >
              <option value="">Select a product</option>
              <%= for product <- @products do %>
                <option value={product.id} selected={@selected_product == "#{product.id}"}><%= product.name %> - $<%= product.price %></option>
              <% end %>
            </select>
          </form>

          <form phx-change="update_quantity" id="quantity-form">
            <input
              type="number"
              name="quantity"
              value={@quantity}
              min="1"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
            />
          </form>

          <button
            phx-click="add_line_item"
            class="mt-1 inline-flex justify-center rounded-md border border-transparent bg-indigo-600 py-2 px-4 text-sm font-medium text-white shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
          >
            Add Item
          </button>
        </div>
      </div>

      <div class="mb-4">
        <h2 class="text-lg font-medium mb-2">Order Items (<%= length(@line_items) %>)</h2>
        <%= if length(@line_items) > 0 do %>
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Product</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Quantity</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Unit Price</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Subtotal</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <%= for item <- @line_items do %>
                <tr>
                  <td class="px-6 py-4 whitespace-nowrap"><%= item.product_name %></td>
                  <td class="px-6 py-4 whitespace-nowrap"><%= item.quantity %></td>
                  <td class="px-6 py-4 whitespace-nowrap">$<%= item.unit_price %></td>
                  <td class="px-6 py-4 whitespace-nowrap">$<%= item.subtotal %></td>
                </tr>
              <% end %>
            </tbody>
          </table>
        <% else %>
          <p class="text-gray-500">No items added yet</p>
        <% end %>
      </div>

      <div class="flex justify-end">
        <button
          phx-click="create_order"
          class="inline-flex justify-center rounded-md border border-transparent bg-indigo-600 py-2 px-4 text-sm font-medium text-white shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
        >
          Create Order
        </button>
      </div>
    </div>
    """
  end
end
