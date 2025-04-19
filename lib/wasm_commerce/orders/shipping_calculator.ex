defmodule WasmCommerce.Orders.ShippingCalculator do
  use Wasmex.Components.ComponentServer,
    wit: "wasm/shipping-calculator.wit",
    imports: %{}

end
