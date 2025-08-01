defmodule WasmCommerce.Accounts.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "customers" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :address, :string
    field :city, :string
    field :state, :string
    field :zip, :string

    has_many :orders, WasmCommerce.Orders.Order

    timestamps()
  end

  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [:name, :email, :phone, :address, :city, :state, :zip])
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> unique_constraint(:email)
  end
end
