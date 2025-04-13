defmodule WasmCommerce.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :total, :decimal
    field :status, :string, default: "pending"

    belongs_to :customer, WasmCommerce.Accounts.Customer
    has_many :line_items, WasmCommerce.Orders.LineItem

    timestamps()
  end

  def changeset(order, attrs) do
    order
    |> cast(attrs, [:total, :status, :customer_id])
    |> validate_required([:customer_id])
    |> validate_inclusion(:status, ["pending", "completed", "cancelled"])
    |> foreign_key_constraint(:customer_id)
  end
end
