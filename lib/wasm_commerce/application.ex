defmodule WasmCommerce.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      WasmCommerceWeb.Telemetry,
      WasmCommerce.Repo,
      {DNSCluster, query: Application.get_env(:wasm_commerce, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: WasmCommerce.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: WasmCommerce.Finch},
      {WasmCommerce.Orders.ShippingCalculator,
       path: "wasm/shipping-calculator.wasm", wasi: %Wasmex.Wasi.WasiP2Options{},
       name: WasmCommerce.Orders.ShippingCalculator},
      # Start a worker by calling: WasmCommerce.Worker.start_link(arg)
      # {WasmCommerce.Worker, arg},
      # Start to serve requests, typically the last entry
      WasmCommerceWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WasmCommerce.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WasmCommerceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
