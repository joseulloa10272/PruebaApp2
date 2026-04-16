import Foundation
import Combine

/// ViewModel that bridges SwiftUI with BluetoothManager.
final class DeviceViewModel: ObservableObject {
    @Published private(set) var connectionState: ConnectionState = .idle
    @Published private(set) var deviceName: String = "—"
    @Published private(set) var latestData: String = "Sin datos"
    @Published private(set) var logs: [BLEMessage] = []
    @Published var sensitivity: Double = 50

    private let bluetoothManager: BluetoothManager
    private var cancellables = Set<AnyCancellable>()

    init(bluetoothManager: BluetoothManager = BluetoothManager()) {
        self.bluetoothManager = bluetoothManager
        bind()
    }

    var isConnected: Bool {
        connectionState == .connected
    }

    func connectOrScan() {
        bluetoothManager.connect()
    }

    func disconnect() {
        bluetoothManager.disconnect()
    }

    func sendCalibration() {
        bluetoothManager.send(command: .calibrate)
    }

    func setVibration(enabled: Bool) {
        bluetoothManager.send(command: .vibration(enabled))
    }

    func sendSensitivity() {
        bluetoothManager.send(command: .sensitivity(Int(sensitivity.rounded())))
    }

    private func bind() {
        bluetoothManager.$connectionState
            .receive(on: DispatchQueue.main)
            .assign(to: &$connectionState)

        bluetoothManager.$connectedDeviceName
            .receive(on: DispatchQueue.main)
            .assign(to: &$deviceName)

        bluetoothManager.$latestData
            .receive(on: DispatchQueue.main)
            .assign(to: &$latestData)

        bluetoothManager.$logs
            .receive(on: DispatchQueue.main)
            .assign(to: &$logs)
    }
}
