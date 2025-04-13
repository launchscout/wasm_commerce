defmodule WasmCommerce.Repo.Migrations.AddShippingToOrders do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :shipping_amount, :decimal, precision: 10, scale: 2, default: 20.00
    end
  end
end
