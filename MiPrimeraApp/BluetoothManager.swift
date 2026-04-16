import Foundation
import CoreBluetooth

/// Handles CoreBluetooth interaction for the prototype communication with ESP32-C6.
final class BluetoothManager: NSObject, ObservableObject {
    @Published private(set) var connectionState: ConnectionState = .idle
    @Published private(set) var connectedDeviceName: String = "—"
    @Published private(set) var latestData: String = "Sin datos"
    @Published private(set) var logs: [BLEMessage] = []

    private var centralManager: CBCentralManager!
    private var targetPeripheral: CBPeripheral?
    private var rxCharacteristic: CBCharacteristic?
    private var txCharacteristic: CBCharacteristic?

    /// PROTOTYPE: Timer used to simulate incoming sensor data until real sensors are integrated.
    private var simulationTimer: Timer?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScan() {
        guard centralManager.state == .poweredOn else {
            connectionState = .bluetoothOff
            appendLog(type: .info, value: "No se puede escanear: Bluetooth no está activo")
            return
        }

        connectionState = .scanning
        appendLog(type: .info, value: "Iniciando escaneo BLE")
        centralManager.scanForPeripherals(withServices: [BLEConstants.serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }

    func connect() {
        if let peripheral = targetPeripheral {
            connectionState = .connecting
            centralManager.connect(peripheral, options: nil)
        } else {
            startScan()
        }
    }

    func disconnect() {
        guard let peripheral = targetPeripheral else { return }
        stopSimulationIfNeeded()
        centralManager.cancelPeripheralConnection(peripheral)
    }

    func send(command: OutgoingCommand) {
        guard connectionState == .connected,
              let peripheral = targetPeripheral,
              let txCharacteristic else {
            appendLog(type: .info, value: "No se pudo enviar comando: no hay conexión activa")
            return
        }

        let payload = command.payload
        guard let data = payload.data(using: .utf8) else { return }
        peripheral.writeValue(data, for: txCharacteristic, type: .withResponse)
        appendLog(type: .info, value: "Enviado -> \(payload)")
    }

    private func appendLog(type: BLEMessageType, value: String) {
        logs.insert(BLEMessage(type: type, value: value, timestamp: Date()), at: 0)
    }

    /// PROTOTYPE: Generates fake posture events to validate UI and BLE message pipeline.
    private func startSimulationIfNeeded() {
        stopSimulationIfNeeded()
        simulationTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            guard let self else { return }
            let random = Bool.random()
            let text = random ? "POSTURE_GOOD" : "POSTURE_BAD"
            self.handleIncomingText(text)
        }
        appendLog(type: .info, value: "Modo prototipo: simulación de datos activa")
    }

    private func stopSimulationIfNeeded() {
        simulationTimer?.invalidate()
        simulationTimer = nil
    }

    private func handleIncomingData(_ data: Data) {
        guard let text = String(data: data, encoding: .utf8) else {
            appendLog(type: .info, value: "Dato recibido no decodificable")
            return
        }
        handleIncomingText(text)
    }

    private func handleIncomingText(_ text: String) {
        latestData = text

        switch text {
        case BLEMessageType.posturaCorrecta.rawValue:
            appendLog(type: .posturaCorrecta, value: "Postura correcta")
        case BLEMessageType.posturaIncorrecta.rawValue:
            appendLog(type: .posturaIncorrecta, value: "Postura incorrecta")
        case BLEMessageType.calibracionRealizada.rawValue:
            appendLog(type: .calibracionRealizada, value: "Calibración realizada")
        default:
            appendLog(type: .info, value: text)
        }
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            connectionState = .idle
            appendLog(type: .info, value: "Bluetooth listo")
        case .poweredOff:
            connectionState = .bluetoothOff
            appendLog(type: .info, value: "Bluetooth apagado")
        default:
            connectionState = .error
            appendLog(type: .info, value: "Bluetooth no disponible: \(central.state.rawValue)")
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        let foundName = peripheral.name ?? (advertisementData[CBAdvertisementDataLocalNameKey] as? String) ?? "Desconocido"
        let uuidMatch = BLEConstants.expectedPeripheralUUID == nil || peripheral.identifier == BLEConstants.expectedPeripheralUUID
        let nameMatch = foundName == BLEConstants.expectedDeviceName

        guard uuidMatch || nameMatch else { return }

        targetPeripheral = peripheral
        targetPeripheral?.delegate = self
        central.stopScan()

        connectionState = .connecting
        connectedDeviceName = foundName
        appendLog(type: .info, value: "Dispositivo encontrado: \(foundName)")
        central.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectionState = .connected
        connectedDeviceName = peripheral.name ?? BLEConstants.expectedDeviceName
        appendLog(type: .info, value: "Conectado a \(connectedDeviceName)")

        peripheral.discoverServices([BLEConstants.serviceUUID])

        // PROTOTYPE: Start simulated incoming stream so UI can be validated without sensors.
        startSimulationIfNeeded()
    }

    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        connectionState = .disconnected
        appendLog(type: .info, value: "Desconectado")
        stopSimulationIfNeeded()

        if let error {
            appendLog(type: .info, value: "Motivo: \(error.localizedDescription)")
        }

        rxCharacteristic = nil
        txCharacteristic = nil
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error {
            appendLog(type: .info, value: "Error al descubrir servicios: \(error.localizedDescription)")
            return
        }

        peripheral.services?.forEach { service in
            if service.uuid == BLEConstants.serviceUUID {
                peripheral.discoverCharacteristics([BLEConstants.rxCharacteristicUUID, BLEConstants.txCharacteristicUUID], for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        if let error {
            appendLog(type: .info, value: "Error al descubrir características: \(error.localizedDescription)")
            return
        }

        service.characteristics?.forEach { characteristic in
            switch characteristic.uuid {
            case BLEConstants.rxCharacteristicUUID:
                rxCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                appendLog(type: .info, value: "RX lista para recibir datos")
            case BLEConstants.txCharacteristicUUID:
                txCharacteristic = characteristic
                appendLog(type: .info, value: "TX lista para enviar comandos")
            default:
                break
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        if let error {
            appendLog(type: .info, value: "Error al recibir dato: \(error.localizedDescription)")
            return
        }

        guard characteristic.uuid == BLEConstants.rxCharacteristicUUID,
              let data = characteristic.value else {
            return
        }

        // FUTURE INTEGRATION: Replace parsing logic here with real sensor packet decoding.
        handleIncomingData(data)
    }
}
