# BLE Prototype Guide (iOS + ESP32-C6)

## Arquitectura propuesta

- **ContentView (SwiftUI)**: pantalla principal con estado de conexión, acciones BLE y registro.
- **DeviceViewModel**: capa de presentación para desacoplar la UI de CoreBluetooth.
- **BluetoothManager**: capa de infraestructura BLE (escaneo, conexión, lectura/escritura, notificaciones).
- **Models / BLEConstants**: contratos compartidos (tipos de mensaje, comandos y UUIDs).

Esta separación permite mantener el prototipo simple hoy y escalar a lógica real de sensores sin rehacer la UI.

## Flujo de conexión BLE

1. La app inicializa `CBCentralManager`.
2. Al presionar **Conectar**, se inicia escaneo del servicio BLE esperado.
3. Si se detecta `PostureESP32` (o UUID configurado), se conecta el periférico.
4. Se descubren el servicio y las características RX/TX.
5. Se activa notificación en RX y escritura en TX.
6. La UI muestra estado, dispositivo, último dato y log.

## Servicio y características esperadas en la ESP32

- **Servicio principal**: `4FAFC201-1FB5-459E-8FCC-C5C9C331914B`
- **RX (ESP32 -> iOS notify/read)**: `BEB5483E-36E1-4688-B7F5-EA07361B26A8`
- **TX (iOS -> ESP32 write)**: `A8F7E7D0-43A5-4B96-AE8F-A2DFA2C1F4E1`

### Payloads de ejemplo

- Eventos desde ESP32: `POSTURE_GOOD`, `POSTURE_BAD`, `CALIBRATED`
- Comandos desde app: `CMD:CALIBRATE`, `CMD:VIBRATION_ON`, `CMD:VIBRATION_OFF`, `CMD:SENSITIVITY:<valor>`

## Cómo reemplazar datos simulados por lecturas reales

Actualmente `BluetoothManager` usa un timer para generar eventos ficticios (`POSTURE_GOOD/BAD`) cuando conecta.

En la siguiente etapa:

1. Eliminar `startSimulationIfNeeded()` y `stopSimulationIfNeeded()`.
2. Mantener `didUpdateValueFor` para procesar únicamente datos reales de la característica RX.
3. Sustituir `handleIncomingText(_:)` por decodificación de paquetes reales de sensores (por ejemplo JSON/binario compacto).
4. Conservar `DeviceViewModel` y `ContentView` sin cambios grandes, porque ya están desacoplados de la fuente de datos.

## Nota de alcance

Este prototipo valida **solo comunicación BLE** (descubrimiento, conexión, lectura y envío de comandos). No incluye lógica médica ni de corrección postural.
