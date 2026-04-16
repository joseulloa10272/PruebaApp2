#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>

// ===== Identidad BLE =====
static const char *DEVICE_NAME = "PostureESP32";

// Servicio principal de postura (UUIDs de ejemplo, reemplazables en el futuro)
static const char *POSTURE_SERVICE_UUID = "5e8d0001-7a44-4e9e-9b66-1b62ea4f0001";

// Características requeridas por la app iOS
static const char *POSTURE_STATE_CHAR_UUID = "5e8d0001-7a44-4e9e-9b66-1b62ea4f1001";
static const char *CALIBRATION_CMD_CHAR_UUID = "5e8d0001-7a44-4e9e-9b66-1b62ea4f1002";
static const char *VIBRATION_CMD_CHAR_UUID = "5e8d0001-7a44-4e9e-9b66-1b62ea4f1003";
static const char *SENSITIVITY_CHAR_UUID = "5e8d0001-7a44-4e9e-9b66-1b62ea4f1004";

BLECharacteristic *postureStateChar = nullptr;
BLECharacteristic *calibrationCmdChar = nullptr;
BLECharacteristic *vibrationCmdChar = nullptr;
BLECharacteristic *sensitivityChar = nullptr;

bool deviceConnected = false;
uint32_t lastPostureUpdateMs = 0;
uint8_t simulatedPostureState = 1; // 1 = postura correcta, 0 = incorrecta
uint8_t sensitivityValue = 5;      // valor de ejemplo (rango esperado: 1-10)

class ServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer *pServer) override {
    deviceConnected = true;
    Serial.println("[BLE] iOS conectada");
  }

  void onDisconnect(BLEServer *pServer) override {
    deviceConnected = false;
    Serial.println("[BLE] iOS desconectada");
    pServer->getAdvertising()->start();
    Serial.println("[BLE] Advertising reiniciado");
  }
};

class CalibrationCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) override {
    std::string value = pCharacteristic->getValue();

    Serial.print("[CMD] Calibración recibida: ");
    if (!value.empty()) {
      Serial.write((const uint8_t *)value.data(), value.length());
    } else {
      Serial.print("(vacío)");
    }
    Serial.println();

    // TODO: Integrar aquí la calibración real cuando haya sensores físicos.
    // Ejemplo futuro: calcular offsets iniciales de IMU y guardarlos en NVS.
  }
};

class VibrationCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) override {
    std::string value = pCharacteristic->getValue();

    Serial.print("[CMD] Vibración recibida: ");
    if (!value.empty()) {
      Serial.write((const uint8_t *)value.data(), value.length());
    } else {
      Serial.print("(vacío)");
    }
    Serial.println();

    // TODO: Integrar aquí el control real del motor de vibración.
    // Ejemplo futuro: activar PWM por N milisegundos según el comando.
  }
};

class SensitivityCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) override {
    std::string value = pCharacteristic->getValue();

    if (!value.empty()) {
      // Se espera un byte de 1-10. Si app envía texto, se puede parsear en otra iteración.
      sensitivityValue = static_cast<uint8_t>(value[0]);
      sensitivityChar->setValue(&sensitivityValue, 1);

      Serial.print("[CMD] Sensibilidad actualizada a: ");
      Serial.println(sensitivityValue);
    } else {
      Serial.println("[CMD] Sensibilidad recibida vacía");
    }

    // TODO: Integrar aquí el uso real de sensibilidad en la detección de postura.
    // Ejemplo futuro: ajustar umbral angular para postura correcta/incorrecta.
  }
};

void setupBLE() {
  BLEDevice::init(DEVICE_NAME);

  BLEServer *server = BLEDevice::createServer();
  server->setCallbacks(new ServerCallbacks());

  BLEService *postureService = server->createService(POSTURE_SERVICE_UUID);

  // 1) Estado de postura: lectura + notificaciones periódicas
  postureStateChar = postureService->createCharacteristic(
      POSTURE_STATE_CHAR_UUID,
      BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY);
  postureStateChar->addDescriptor(new BLE2902());
  postureStateChar->setValue(&simulatedPostureState, 1);

  // 2) Comando de calibración: escritura desde app
  calibrationCmdChar = postureService->createCharacteristic(
      CALIBRATION_CMD_CHAR_UUID,
      BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_WRITE_NR);
  calibrationCmdChar->setCallbacks(new CalibrationCallbacks());

  // 3) Comando de vibración: escritura desde app
  vibrationCmdChar = postureService->createCharacteristic(
      VIBRATION_CMD_CHAR_UUID,
      BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_WRITE_NR);
  vibrationCmdChar->setCallbacks(new VibrationCallbacks());

  // 4) Sensibilidad: lectura/escritura
  sensitivityChar = postureService->createCharacteristic(
      SENSITIVITY_CHAR_UUID,
      BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE);
  sensitivityChar->setCallbacks(new SensitivityCallbacks());
  sensitivityChar->setValue(&sensitivityValue, 1);

  postureService->start();

  BLEAdvertising *advertising = BLEDevice::getAdvertising();
  advertising->addServiceUUID(POSTURE_SERVICE_UUID);
  advertising->setScanResponse(true);
  advertising->setMinPreferred(0x06);
  advertising->setMinPreferred(0x12);

  BLEDevice::startAdvertising();
  Serial.println("[BLE] Advertising iniciado como PostureESP32");
}

void setup() {
  Serial.begin(115200);
  delay(200);

  Serial.println("\n=== PostureESP32 BLE Prototype ===");
  Serial.println("Firmware de validación BLE para app iOS (sin sensores físicos)");

  // TODO: Inicializar aquí sensores reales (IMU, flex, etc.) cuando estén conectados.
  setupBLE();
}

void loop() {
  const uint32_t now = millis();
  const uint32_t intervalMs = 2000; // envío periódico simulado cada 2 s

  if (now - lastPostureUpdateMs >= intervalMs) {
    lastPostureUpdateMs = now;

    // Simulación de postura: alterna entre correcta e incorrecta.
    // TODO: Reemplazar con lectura de sensores reales y algoritmo de clasificación.
    simulatedPostureState = (simulatedPostureState == 1) ? 0 : 1;

    postureStateChar->setValue(&simulatedPostureState, 1);

    if (deviceConnected) {
      postureStateChar->notify();
    }

    Serial.print("[SIM] Estado de postura enviado: ");
    Serial.println(simulatedPostureState == 1 ? "CORRECTA" : "INCORRECTA");
  }

  delay(10);
}
