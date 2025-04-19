defmodule WasmCommerce.Repo.Migrations.AddAddressFieldsToCustomers do
  use Ecto.Migration

  def change do
    alter table(:customers) do
      add :city, :string
      add :state, :string
      add :zip, :string
    end
  end
end
