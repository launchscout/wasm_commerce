defmodule WasmCommerce.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :total, :decimal, precision: 10, scale: 2
      add :status, :string, null: false, default: "pending"
      add :customer_id, references(:customers, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:orders, [:customer_id])
  end
end
