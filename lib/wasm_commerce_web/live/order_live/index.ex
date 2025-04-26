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
    <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
      <div class="md:flex md:items-center md:justify-between mb-8">
        <div class="flex-1 min-w-0">
          <h2 class="text-2xl font-bold leading-7 text-gray-900 sm:text-3xl sm:truncate">Orders</h2>
          <p class="mt-1 text-sm text-gray-500">Manage all your customer orders in one place.</p>
        </div>
        <div class="mt-4 flex md:mt-0 md:ml-4">
          <a
            href={~p"/orders/new"}
            class="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="-ml-1 mr-2 h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
            </svg>
            New Order
          </a>
        </div>
      </div>

      <div class="bg-white shadow overflow-hidden sm:rounded-md">
        <ul role="list" class="divide-y divide-gray-200">
          <%= for order <- @orders do %>
            <li>
              <a href={~p"/orders/#{order.id}"} class="block hover:bg-gray-50">
                <div class="px-4 py-4 sm:px-6">
                  <div class="flex items-center justify-between">
                    <div class="flex items-center">
                      <p class="text-sm font-medium text-indigo-600 truncate">Order #<%= order.id %></p>
                      <div class="ml-2 flex-shrink-0 flex">
                        <p class={"px-2 inline-flex text-xs leading-5 font-semibold rounded-full #{status_bg_color(order.status)} #{status_text_color(order.status)}"}>
                          <%= String.capitalize(order.status) %>
                        </p>
                      </div>
                    </div>
                    <div class="ml-2 flex-shrink-0 flex">
                      <p class="text-sm text-gray-500">$<%= order.total %></p>
                    </div>
                  </div>
                  <div class="mt-2 sm:flex sm:justify-between">
                    <div class="sm:flex">
                      <p class="flex items-center text-sm text-gray-500">
                        <svg class="flex-shrink-0 mr-1.5 h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                          <path d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" />
                        </svg>
                        <%= order.customer.name %>
                      </p>
                    </div>
                    <div class="mt-2 flex items-center text-sm text-gray-500 sm:mt-0">
                      <svg class="flex-shrink-0 mr-1.5 h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                        <path fill-rule="evenodd" d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z" clip-rule="evenodd" />
                      </svg>
                      <p>
                        Created on <%= format_date(order.inserted_at) %>
                      </p>
                    </div>
                  </div>
                </div>
              </a>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  defp status_bg_color("pending"), do: "bg-yellow-100"
  defp status_bg_color("completed"), do: "bg-green-100"
  defp status_bg_color("cancelled"), do: "bg-red-100"

  defp status_text_color("pending"), do: "text-yellow-800"
  defp status_text_color("completed"), do: "text-green-800"
  defp status_text_color("cancelled"), do: "text-red-800"

  defp format_date(datetime) do
    datetime
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.to_date()
    |> Date.to_string()
  end
end
