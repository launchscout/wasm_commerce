defmodule WasmCommerce.Orders do
  import Ecto.Query, warn: false
  alias WasmCommerce.Repo
  alias WasmCommerce.Orders.{Order, LineItem}
  alias WasmCommerce.Catalog.Product
  alias WasmCommerce.Orders.ShippingCalculator

  def list_orders do
    Repo.all(Order)
    |> Repo.preload([:customer, line_items: :product])
  end

  def get_order!(id) do
    Repo.get!(Order, id)
    |> Repo.preload([:customer, line_items: :product])
  end

  def create_order(attrs \\ %{}) do
    %Order{}
    |> Order.changeset(attrs)
    |> Repo.insert()
  end

  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end

  def change_order(%Order{} = order, attrs \\ %{}) do
    Order.changeset(order, attrs)
  end

  def create_line_item(attrs \\ %{}) do
    %LineItem{}
    |> LineItem.changeset(attrs)
    |> Repo.insert()
  end

  def update_line_item(%LineItem{} = line_item, attrs) do
    line_item
    |> LineItem.changeset(attrs)
    |> Repo.update()
  end

  def delete_line_item(%LineItem{} = line_item) do
    Repo.delete(line_item)
  end

  def change_line_item(%LineItem{} = line_item, attrs \\ %{}) do
    LineItem.changeset(line_item, attrs)
  end

  def calculate_order_total(order_id) do
    line_items = Repo.all(from li in LineItem, where: li.order_id == ^order_id)

    # Calculate subtotal from line items
    subtotal = Enum.reduce(line_items, Decimal.new("0"), fn item, acc ->
      Decimal.add(acc, item.subtotal)
    end)

    # Get order to retrieve shipping amount
    order = get_order!(order_id)
    shipping = shipping_amount(order) |> IO.inspect(label: "shipping")

    # Add shipping to get total
    total = Decimal.add(subtotal, shipping)

    # Update order
    update_order(order, %{total: total, shipping_amount: shipping})
  end

  # def shipping_amount(_), do: Decimal.new("10.0")

  def shipping_amount(order) do
    order = to_cents(order)
    IO.inspect(order)
    {:ok, shipping_cents} = ShippingCalculator.calculate_shipping(order)
    Decimal.from_float(shipping_cents / 100)
  end

  @doc """
  Converts all decimal fields in an order and its line items to integer cents.
  Returns a map with the same structure but with decimal values converted to integers.
  """
  def to_cents(%Order{} = order) do
    line_items = Enum.map(order.line_items || [], fn item ->
      product = if item.product do
        %{
          "price-cents" => decimal_to_cents(item.product.price),
          "stock-quantity" => item.product.stock_quantity,
          id: item.product.id,
          name: item.product.name,
          description: item.product.description,
          sku: item.product.sku
        }
      else
        nil
      end

      %{
        "unit-price-cents" => decimal_to_cents(item.unit_price),
        "subtotal-cents" => decimal_to_cents(item.subtotal),
        "order-id" => item.order_id,
        "product-id" => item.product_id,
        id: item.id,
        quantity: item.quantity,
        product: product
      }
    end)

    %{
      "total-cents" => decimal_to_cents(order.total),
      "shipping-amount-cents" => decimal_to_cents(order.shipping_amount),
      "line-items" => line_items,
      "customer-id" => order.customer_id,
      id: order.id,
      status: order.status,
      customer: order.customer
    }
  end

  # Helper to convert a decimal to integer cents
  defp decimal_to_cents(nil), do: 0
  defp decimal_to_cents(decimal) do
    decimal
    |> Decimal.mult(Decimal.new("100"))
    |> Decimal.round(0)
    |> Decimal.to_integer()
  end
end
