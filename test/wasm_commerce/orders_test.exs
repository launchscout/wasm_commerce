defmodule WasmCommerce.OrdersTest do
  use WasmCommerce.DataCase

  alias WasmCommerce.Orders
  alias WasmCommerce.Orders.{Order, LineItem}
  alias WasmCommerce.Accounts
  alias WasmCommerce.Catalog

  describe "to_cents/1" do
    test "converts order decimal fields to integer cents" do
      # Setup: Create a customer for the order
      {:ok, customer} = Accounts.create_customer(%{
        name: "Test Customer",
        email: "test@example.com"
      })

      # Create a product for the line item
      {:ok, product} = Catalog.create_product(%{
        name: "Test Product",
        description: "Description",
        price: Decimal.new("19.99"),
        sku: "TEST123",
        stock_quantity: 100
      })

      # Create an order with line items
      {:ok, order} = Orders.create_order(%{
        customer_id: customer.id,
        shipping_amount: Decimal.new("5.95"),
        total: Decimal.new("45.93")
      })

      # Create a line item for the order
      {:ok, _line_item} = Orders.create_line_item(%{
        order_id: order.id,
        product_id: product.id,
        quantity: 2,
        unit_price: Decimal.new("19.99"),
        subtotal: Decimal.new("39.98")
      })

      # Reload the order with associations
      order = Orders.get_order!(order.id)

      # Execute the function
      result = Orders.to_cents(order)

      # Verify the results
      assert result.total_cents == 4593
      assert result.shipping_amount_cents == 595
      assert length(result.line_items) == 1

      line_item = hd(result.line_items)
      assert line_item.unit_price_cents == 1999
      assert line_item.subtotal_cents == 3998

      # Verify product price is converted
      assert line_item.product.price_cents == 1999
    end

    test "handles nil decimal values" do
      # Setup: Create a customer for the order
      {:ok, customer} = Accounts.create_customer(%{
        name: "Test Customer",
        email: "test@example.com"
      })

      # Create an order with nil values
      {:ok, order} = Orders.create_order(%{
        customer_id: customer.id,
        shipping_amount: nil,
        total: nil
      })

      # Reload the order
      order = Orders.get_order!(order.id)

      # Execute the function
      result = Orders.to_cents(order)

      # Verify the results
      assert result.total_cents == nil
      assert result.shipping_amount_cents == nil
    end
  end
end
