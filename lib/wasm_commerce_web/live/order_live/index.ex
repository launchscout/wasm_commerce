defmodule WasmCommerceWeb.OrderLive.Index do
  use WasmCommerceWeb, :live_view
  alias WasmCommerce.Orders

  def mount(_params, _session, socket) do
    orders = Orders.list_orders()

    {:ok, assign(socket,
      orders: orders,
      page_title: "Orders"
    )}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto p-4">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-bold">Orders</h1>
        <a
          href={~p"/orders/new"}
          class="inline-flex justify-center rounded-md border border-transparent bg-indigo-600 py-2 px-4 text-sm font-medium text-white shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
        >
          New Order
        </a>
      </div>

      <div class="bg-white shadow rounded-lg overflow-hidden">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Order ID</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Customer</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Total</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Created At</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <%= for order <- @orders do %>
              <tr>
                <td class="px-6 py-4 whitespace-nowrap">#<%= order.id %></td>
                <td class="px-6 py-4 whitespace-nowrap"><%= order.customer.name %></td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span class={"px-3 py-1 rounded-full text-sm font-medium #{status_color(order.status)}"}>
                    <%= String.capitalize(order.status) %>
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">$<%= order.total %></td>
                <td class="px-6 py-4 whitespace-nowrap"><%= format_date(order.inserted_at) %></td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <a
                    href={~p"/orders/#{order.id}"}
                    class="text-indigo-600 hover:text-indigo-900"
                  >
                    View
                  </a>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  defp status_color("pending"), do: "bg-yellow-100 text-yellow-800"
  defp status_color("completed"), do: "bg-green-100 text-green-800"
  defp status_color("cancelled"), do: "bg-red-100 text-red-800"

  defp format_date(datetime) do
    datetime
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.to_date()
    |> Date.to_string()
  end
end
