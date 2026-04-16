# PostureESP32 BLE Prototype (XIAO ESP32-C6)

Prototipo de firmware para validar la comunicación BLE con una app iOS, sin sensores físicos conectados todavía.

## Identidad BLE
- **Nombre del periférico:** `PostureESP32`
- **Servicio principal de postura:** `5e8d0001-7a44-4e9e-9b66-1b62ea4f0001`

## Características
1. **Estado de postura** (`READ`, `NOTIFY`)
   - UUID: `5e8d0001-7a44-4e9e-9b66-1b62ea4f1001`
   - Payload actual: 1 byte (`1 = correcta`, `0 = incorrecta`)
   - Envío simulado cada 2 segundos.

2. **Comando de calibración** (`WRITE`, `WRITE WITHOUT RESPONSE`)
   - UUID: `5e8d0001-7a44-4e9e-9b66-1b62ea4f1002`
   - Cualquier dato escrito se registra por `Serial`.

3. **Comando de vibración** (`WRITE`, `WRITE WITHOUT RESPONSE`)
   - UUID: `5e8d0001-7a44-4e9e-9b66-1b62ea4f1003`
   - Cualquier dato escrito se registra por `Serial`.

4. **Sensibilidad** (`READ`, `WRITE`)
   - UUID: `5e8d0001-7a44-4e9e-9b66-1b62ea4f1004`
   - Payload actual: 1 byte (`1..10`, ejemplo).
   - Al escribir, se actualiza el valor interno y se registra por `Serial`.

## Archivo principal
- `PostureESP32.ino`

## Próximos pasos
- Integrar lectura real de sensores de postura (IMU/flex/etc.).
- Sustituir la simulación por lógica real de clasificación.
- Mapear comandos de vibración/calibración a hardware.
