defmodule WasmCommerce.Orders.ShippingCalculator do
  use Wasmex.Components.ComponentServer,
    wit: "wasm/shipping-calculator.wit",
    imports: %{
      "product-surcharge" => {:fn, &get_product_surcharge/1}
    }

  def calculate_shipping(order), do: calculate_shipping(__MODULE__, order)

  def get_product_surcharge(%{name: product_name}) do
    if String.contains?(product_name, "Premium") do
      500
    else
      0
    end
  end
end
