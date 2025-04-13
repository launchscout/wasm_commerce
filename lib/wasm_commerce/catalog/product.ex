defmodule WasmCommerce.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :name, :string
    field :description, :string
    field :price, :decimal
    field :sku, :string
    field :stock_quantity, :integer

    has_many :line_items, WasmCommerce.Orders.LineItem

    timestamps()
  end

  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :description, :price, :sku, :stock_quantity])
    |> validate_required([:name, :price, :sku, :stock_quantity])
    |> validate_number(:price, greater_than: 0)
    |> validate_number(:stock_quantity, greater_than_or_equal_to: 0)
    |> unique_constraint(:sku)
  end
end
