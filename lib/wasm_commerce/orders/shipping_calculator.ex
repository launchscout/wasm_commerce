defmodule WasmCommerce.Orders.ShippingCalculator do
  use Wasmex.Components.ComponentServer,
    wit: "wasm/shipping-calculator.wit",
    imports: %{}

  def calculate_shipping(order), do: calculate_shipping(__MODULE__, order)
end
