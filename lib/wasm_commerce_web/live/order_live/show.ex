defmodule WasmCommerceWeb.OrderLive.Show do
  use WasmCommerceWeb, :live_view
  alias WasmCommerce.Orders

  def mount(%{"id" => id}, _session, socket) do
    order = Orders.get_order!(id)

    # Calculate subtotal (total - shipping)
    subtotal = if order.total && order.shipping_amount do
      Decimal.sub(order.total || Decimal.new("0"), order.shipping_amount || Decimal.new("0"))
    else
      Decimal.new("0")
    end

    {:ok, assign(socket,
      order: order,
      subtotal: subtotal,
      page_title: "Order #{order.id}"
    )}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto p-4">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-bold">Order #{@order.id}</h1>
        <span class={"px-3 py-1 rounded-full text-sm font-medium #{status_color(@order.status)}"}>
          <%= String.capitalize(@order.status) %>
        </span>
      </div>

      <div class="bg-white shadow rounded-lg p-6 mb-6">
        <h2 class="text-lg font-medium mb-4">Customer Information</h2>
        <div class="grid grid-cols-2 gap-4">
          <div>
            <p class="text-sm text-gray-500">Name</p>
            <p class="font-medium"><%= @order.customer.name %></p>
          </div>
          <div>
            <p class="text-sm text-gray-500">Email</p>
            <p class="font-medium"><%= @order.customer.email %></p>
          </div>
          <div>
            <p class="text-sm text-gray-500">Phone</p>
            <p class="font-medium"><%= @order.customer.phone %></p>
          </div>
          <div>
            <p class="text-sm text-gray-500">Address</p>
            <p class="font-medium"><%= @order.customer.address %></p>
          </div>
        </div>
      </div>

      <div class="bg-white shadow rounded-lg p-6 mb-6">
        <h2 class="text-lg font-medium mb-4">Order Items</h2>
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
            <%= for item <- @order.line_items do %>
              <tr>
                <td class="px-6 py-4 whitespace-nowrap"><%= item.product.name %></td>
                <td class="px-6 py-4 whitespace-nowrap"><%= item.quantity %></td>
                <td class="px-6 py-4 whitespace-nowrap">$<%= item.unit_price %></td>
                <td class="px-6 py-4 whitespace-nowrap">$<%= item.subtotal %></td>
              </tr>
            <% end %>
          </tbody>
          <tfoot class="bg-gray-50">
            <tr>
              <td colspan="3" class="px-6 py-2 text-right font-medium">Subtotal</td>
              <td class="px-6 py-2 font-medium">$<%= @subtotal %></td>
            </tr>
            <tr>
              <td colspan="3" class="px-6 py-2 text-right font-medium">Shipping</td>
              <td class="px-6 py-2 font-medium">$<%= @order.shipping_amount %></td>
            </tr>
            <tr>
              <td colspan="3" class="px-6 py-4 text-right font-bold text-lg">Total</td>
              <td class="px-6 py-4 font-bold text-lg">$<%= @order.total %></td>
            </tr>
          </tfoot>
        </table>
      </div>

      <div class="flex justify-end">
        <a
          href={~p"/orders"}
          class="inline-flex justify-center rounded-md border border-transparent bg-indigo-600 py-2 px-4 text-sm font-medium text-white shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
        >
          Back to Orders
        </a>
      </div>
    </div>
    """
  end

  defp status_color("pending"), do: "bg-yellow-100 text-yellow-800"
  defp status_color("completed"), do: "bg-green-100 text-green-800"
  defp status_color("cancelled"), do: "bg-red-100 text-red-800"
end
