defmodule WasmCommerce.Repo.Migrations.CreateLineItems do
  use Ecto.Migration

  def change do
    create table(:line_items) do
      add :quantity, :integer, null: false
      add :unit_price, :decimal, precision: 10, scale: 2, null: false
      add :subtotal, :decimal, precision: 10, scale: 2, null: false
      add :order_id, references(:orders, on_delete: :delete_all), null: false
      add :product_id, references(:products, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:line_items, [:order_id])
    create index(:line_items, [:product_id])
  end
end
