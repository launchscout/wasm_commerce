defmodule WasmCommerce.Repo do
  use Ecto.Repo,
    otp_app: :wasm_commerce,
    adapter: Ecto.Adapters.Postgres
end
