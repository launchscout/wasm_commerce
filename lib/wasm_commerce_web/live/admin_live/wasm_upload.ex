defmodule WasmCommerceWeb.AdminLive.WasmUpload do
  use WasmCommerceWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> assign(:upload_status, nil)
     |> allow_upload(:wasm_binary,
       accept: ~w(.wasm),
       max_entries: 1,
       max_file_size: 50_000_000
     )}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :wasm_binary, ref)}
  end

  @impl true
  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :wasm_binary, fn %{path: path}, _entry ->
        dest = Path.join("priv/wasm", "shipping-calculator.wasm")

        # Create backup of current WASM file
        backup_path = Path.join("priv/wasm", "shipping-calculator.wasm.backup")
        File.cp(dest, backup_path)

        # Copy new WASM file
        File.cp!(path, dest)

        {:ok, dest}
      end)

    case uploaded_files do
      [wasm_path] ->
        # Restart the ShippingCalculator process
        case restart_shipping_calculator() do
          :ok ->
            {:noreply,
             socket
             |> put_flash(:info, "WASM binary uploaded successfully and ShippingCalculator restarted!")
             |> assign(:upload_status, :success)
             |> assign(:uploaded_files, [])}

          {:error, reason} ->
            # Restore backup on failure
            backup_path = Path.join("priv/wasm", "shipping-calculator.wasm.backup")
            File.cp!(backup_path, wasm_path)

            {:noreply,
             socket
             |> put_flash(:error, "Failed to restart ShippingCalculator: #{inspect(reason)}. Previous version restored.")
             |> assign(:upload_status, :error)}
        end

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to upload WASM binary")
         |> assign(:upload_status, :error)}
    end
  end

  defp restart_shipping_calculator do
    # Get the current process
    case Process.whereis(WasmCommerce.Orders.ShippingCalculator) do
      nil ->
        {:error, :process_not_found}

      pid ->
        # Stop the current process
        Supervisor.terminate_child(WasmCommerce.Supervisor, WasmCommerce.Orders.ShippingCalculator)
        Supervisor.delete_child(WasmCommerce.Supervisor, WasmCommerce.Orders.ShippingCalculator)

        # Start a new process with the updated WASM binary
        child_spec = {WasmCommerce.Orders.ShippingCalculator,
          path: "priv/wasm/shipping-calculator.wasm",
          wasi: %Wasmex.Wasi.WasiP2Options{allow_http: true},
          name: WasmCommerce.Orders.ShippingCalculator}

        case Supervisor.start_child(WasmCommerce.Supervisor, child_spec) do
          {:ok, _pid} -> :ok
          {:error, reason} -> {:error, reason}
        end
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl">
      <.header>
        Upload WASM Binary
        <:subtitle>Upload a new shipping calculator WebAssembly component</:subtitle>
      </.header>

      <div class="mt-10">
        <form id="upload-form" phx-submit="save" phx-change="validate">
          <div class="space-y-6">
            <div class="rounded-lg border border-gray-300 bg-white p-6">
              <div class="space-y-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700">
                    Current WASM Binary
                  </label>
                  <p class="mt-1 text-sm text-gray-500">
                    Location: priv/wasm/shipping-calculator.wasm
                  </p>
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">
                    Upload New WASM Binary
                  </label>

                  <.live_file_input upload={@uploads.wasm_binary} />

                  <div :if={@uploads.wasm_binary.entries != []}>
                    <h3 class="mt-4 text-sm font-medium text-gray-700">Selected file:</h3>
                    <div class="mt-2">
                      <%= for entry <- @uploads.wasm_binary.entries do %>
                        <div class="flex items-center justify-between rounded-md border border-gray-200 p-2">
                          <div class="flex items-center space-x-2">
                            <span class="text-sm text-gray-600"><%= entry.client_name %></span>
                            <span class="text-xs text-gray-400">
                              (<%= Float.round(entry.client_size / 1024, 1) %> KB)
                            </span>
                          </div>

                          <button
                            type="button"
                            phx-click="cancel-upload"
                            phx-value-ref={entry.ref}
                            class="text-red-500 hover:text-red-700"
                          >
                            <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                            </svg>
                          </button>
                        </div>

                        <div :for={err <- upload_errors(@uploads.wasm_binary, entry)} class="mt-2">
                          <p class="text-sm text-red-600"><%= err %></p>
                        </div>
                      <% end %>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div class="flex justify-end space-x-3">
              <.link navigate={~p"/"} class="rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50">
                Cancel
              </.link>

              <button
                type="submit"
                disabled={@uploads.wasm_binary.entries == []}
                class="rounded-md bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed"
              >
                Upload
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
    """
  end
end
