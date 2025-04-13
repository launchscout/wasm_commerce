defmodule WasmCommerce.Orders.LineItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "line_items" do
    field :quantity, :integer
    field :unit_price, :decimal
    field :subtotal, :decimal

    belongs_to :order, WasmCommerce.Orders.Order
    belongs_to :product, WasmCommerce.Catalog.Product

    timestamps()
  end

  def changeset(line_item, attrs) do
    line_item
    |> cast(attrs, [:quantity, :unit_price, :subtotal, :order_id, :product_id])
    |> validate_required([:quantity, :unit_price, :subtotal, :order_id, :product_id])
    |> validate_number(:quantity, greater_than: 0)
    |> validate_number(:unit_price, greater_than: 0)
    |> validate_number(:subtotal, greater_than: 0)
    |> foreign_key_constraint(:order_id)
    |> foreign_key_constraint(:product_id)
  end
end
