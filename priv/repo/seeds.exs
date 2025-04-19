# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     WasmCommerce.Repo.insert!(%WasmCommerce.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias WasmCommerce.{Accounts, Catalog, Repo}

# Create customers
customers = [
  %{
    name: "John Smith",
    email: "john.smith@example.com",
    phone: "555-123-4567",
    address: "123 Main St",
    city: "Anytown",
    state: "CA",
    zip: "12345"
  },
  %{
    name: "Sarah Johnson",
    email: "sarah.j@example.com",
    phone: "555-987-6543",
    address: "456 Oak Ave",
    city: "Somewhere",
    state: "NY",
    zip: "67890"
  },
  %{
    name: "Michael Brown",
    email: "m.brown@example.com",
    phone: "555-555-5555",
    address: "789 Pine Rd",
    city: "Elsewhere",
    state: "TX",
    zip: "54321"
  }
]

Enum.each(customers, fn customer ->
  Accounts.create_customer(customer)
end)

# Create products
products = [
  %{
    name: "Premium Widget",
    description: "A high-quality widget for all your widget needs",
    price: "29.99",
    sku: "WID-001",
    stock_quantity: 100
  },
  %{
    name: "Deluxe Gadget",
    description: "The latest and greatest gadget on the market",
    price: "49.99",
    sku: "GAD-001",
    stock_quantity: 50
  },
  %{
    name: "Basic Thingamajig",
    description: "A simple but reliable thingamajig",
    price: "19.99",
    sku: "THI-001",
    stock_quantity: 200
  },
  %{
    name: "Super Doohickey",
    description: "An advanced doohickey with all the features",
    price: "79.99",
    sku: "DOO-001",
    stock_quantity: 30
  }
]

Enum.each(products, fn product ->
  Catalog.create_product(product)
end)
