defmodule WasmCommerce.Repo.Migrations.CreateCustomers do
  use Ecto.Migration

  def change do
    create table(:customers) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :phone, :string
      add :address, :string

      timestamps()
    end

    create unique_index(:customers, [:email])
  end
end
