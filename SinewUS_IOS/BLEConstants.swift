// ============================================================
// BLEConstants.swift — BLE UUIDs and device config
// Must match the ESP32 firmware values exactly
// ============================================================

import CoreBluetooth

struct BLEConstants {
    // Advertised device name from ESP32
    static let deviceName = "SinewUS"

    // BLE service UUID (matches firmware/sinew_esp32.ino)
    static let serviceUUID = CBUUID(string: "12345678-1234-5678-1234-56789abcdef0")

    // BLE characteristic UUID (matches firmware/sinew_esp32.ino)
    static let characteristicUUID = CBUUID(string: "abcdef01-1234-5678-1234-56789abcdef0")

    // Scan timeout in seconds
    static let scanTimeout: TimeInterval = 10
}
