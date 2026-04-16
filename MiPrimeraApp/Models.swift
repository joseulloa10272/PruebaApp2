import Foundation

enum BLEMessageType: String, Codable {
    case posturaCorrecta = "POSTURE_GOOD"
    case posturaIncorrecta = "POSTURE_BAD"
    case calibracionRealizada = "CALIBRATED"
    case sensibilidad = "SENSITIVITY"
    case info = "INFO"
}

struct BLEMessage: Identifiable, Codable {
    let id = UUID()
    let type: BLEMessageType
    let value: String
    let timestamp: Date

    var displayText: String {
        "[\(timestamp.formatted(date: .omitted, time: .standard))] \(type.rawValue): \(value)"
    }
}

enum ConnectionState: String {
    case bluetoothOff = "Bluetooth apagado"
    case idle = "Sin conexión"
    case scanning = "Escaneando"
    case connecting = "Conectando"
    case connected = "Conectado"
    case disconnected = "Desconectado"
    case error = "Error"
}

enum OutgoingCommand {
    case calibrate
    case vibration(Bool)
    case sensitivity(Int)

    var payload: String {
        switch self {
        case .calibrate:
            return "CMD:CALIBRATE"
        case .vibration(let enabled):
            return enabled ? "CMD:VIBRATION_ON" : "CMD:VIBRATION_OFF"
        case .sensitivity(let value):
            return "CMD:SENSITIVITY:\(value)"
        }
    }
}
