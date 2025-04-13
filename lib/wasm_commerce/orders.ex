defmodule WasmCommerce.Orders do
  import Ecto.Query, warn: false
  alias WasmCommerce.Repo
  alias WasmCommerce.Orders.{Order, LineItem}
  alias WasmCommerce.Catalog.Product

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
    shipping = order.shipping_amount || Decimal.new("20.00")

    # Add shipping to get total
    total = Decimal.add(subtotal, shipping)

    # Update order
    update_order(order, %{total: total})
  end
end
