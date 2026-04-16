import Foundation
import CoreBluetooth

/// BLE UUIDs and app-level identifiers used by the prototype.
enum BLEConstants {
    /// Human-readable BLE name expected from ESP32-C6 advertisement packets.
    static let expectedDeviceName = "PostureESP32"

    /// Optional fixed peripheral UUID for debugging environments.
    /// Leave as `nil` to connect by advertised name.
    static let expectedPeripheralUUID: UUID? = nil

    /// Custom service UUID expected on the ESP32-C6.
    static let serviceUUID = CBUUID(string: "4FAFC201-1FB5-459E-8FCC-C5C9C331914B")

    /// Characteristic used by ESP32 -> iOS notifications (posture/status events).
    static let rxCharacteristicUUID = CBUUID(string: "BEB5483E-36E1-4688-B7F5-EA07361B26A8")

    /// Characteristic used by iOS -> ESP32 writes (commands).
    static let txCharacteristicUUID = CBUUID(string: "A8F7E7D0-43A5-4B96-AE8F-A2DFA2C1F4E1")
}
