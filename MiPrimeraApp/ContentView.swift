import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DeviceViewModel()
    @State private var vibrationEnabled = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    connectionCard
                    actionCard
                    sensitivityCard
                    logCard
                }
                .padding()
            }
            .navigationTitle("Posture BLE Prototype")
        }
    }

    private var connectionCard: some View {
        GroupBox("Estado del dispositivo") {
            VStack(alignment: .leading, spacing: 10) {
                statusRow("Estado", viewModel.connectionState.rawValue)
                statusRow("Dispositivo", viewModel.deviceName)
                statusRow("Último dato", viewModel.latestData)

                HStack(spacing: 12) {
                    Button(viewModel.isConnected ? "Desconectar" : "Conectar") {
                        viewModel.isConnected ? viewModel.disconnect() : viewModel.connectOrScan()
                    }
                    .buttonStyle(.borderedProminent)

                    if !viewModel.isConnected {
                        Text("Busca \(BLEConstants.expectedDeviceName)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var actionCard: some View {
        GroupBox("Comandos") {
            VStack(alignment: .leading, spacing: 12) {
                Button("Enviar calibración") {
                    viewModel.sendCalibration()
                }
                .buttonStyle(.bordered)

                Toggle("Vibración", isOn: $vibrationEnabled)
                    .onChange(of: vibrationEnabled) { _, newValue in
                        viewModel.setVibration(enabled: newValue)
                    }
            }
        }
    }

    private var sensitivityCard: some View {
        GroupBox("Sensibilidad simulada") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Valor actual: \(Int(viewModel.sensitivity))")
                Slider(value: $viewModel.sensitivity, in: 1...100, step: 1)
                Button("Enviar sensibilidad") {
                    viewModel.sendSensitivity()
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var logCard: some View {
        GroupBox("Registro de mensajes") {
            if viewModel.logs.isEmpty {
                Text("Sin mensajes todavía")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.logs.prefix(20)) { item in
                        Text(item.displayText)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }

    private func statusRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ContentView()
}
