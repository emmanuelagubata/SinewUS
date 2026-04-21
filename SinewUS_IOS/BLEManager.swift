// ============================================================
// BLEManager.swift — CoreBluetooth manager for scanning,
// connecting, and streaming data from the ESP32
// ============================================================

import Foundation //apple's base library for swift files
import CoreBluetooth //Apple's BLE framework, without it cant speak BLE

struct DiscoveredDevice: Identifiable {
    let id: UUID //unique identifier
    let name: String //human readable name
    let rssi: Int //signal strength in dBm
    let peripheral: CBPeripheral //actual CoreBluetooth object represeting that ESP32
}

enum ConnectionState: String {
    case disconnected = "Disconnected"
    case scanning = "Scanning..."
    case connecting = "Connecting..."
    case connected = "Connected"
}

class BLEManager: NSObject, ObservableObject {

    @Published var connectionState: ConnectionState = .disconnected
    @Published var discoveredDevices: [DiscoveredDevice] = []
    @Published var currentForce: Double = 0.0
    @Published var isReceivingData = false

    var onDataPoint: ((Double) -> Void)?

    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var dataCharacteristic: CBCharacteristic?
    private var controlCharacteristic: CBCharacteristic?
    private var scanTimer: Timer?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScan() {
        guard centralManager.state == .poweredOn else { return }
        // Stop any previous scan so iOS clears its cache
        centralManager.stopScan()
        discoveredDevices = []
        connectionState = .scanning
        // AllowDuplicates = true so iOS reports the device every advertising packet,
        // not just the first time it sees it. This fixes the "device doesn't show up" issue.
        centralManager.scanForPeripherals(
            withServices: [BLEConstants.serviceUUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        )
        scanTimer = Timer.scheduledTimer(withTimeInterval: BLEConstants.scanTimeout, repeats: false) { [weak self] _ in
            self?.stopScan()
        }
    }

    func stopScan() {
        centralManager.stopScan()
        scanTimer?.invalidate()
        scanTimer = nil
        if connectionState == .scanning { connectionState = .disconnected }
    }

    func connect(to device: DiscoveredDevice) {
        stopScan()
        connectionState = .connecting
        connectedPeripheral = device.peripheral
        connectedPeripheral?.delegate = self
        centralManager.connect(device.peripheral, options: nil)
    }

    func disconnect() {
        sendCommand("STOP")
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        cleanup()
    }

    /// Send a command ("START" or "STOP") to the ESP32 control characteristic
    func sendCommand(_ command: String) {
        guard let peripheral = connectedPeripheral,
              let control = controlCharacteristic,
              let data = command.data(using: .utf8) else { return }
        peripheral.writeValue(data, for: control, type: .withResponse)
    }

    private func cleanup() {
        connectedPeripheral = nil
        dataCharacteristic = nil
        controlCharacteristic = nil
        connectionState = .disconnected
        isReceivingData = false
    }
}

// MARK: - CBCentralManagerDelegate

extension BLEManager: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn { cleanup() }
    }

    func centralManager(_ central: CBCentralManager,
                         didDiscover peripheral: CBPeripheral,
                         advertisementData: [String: Any],
                         rssi RSSI: NSNumber) {
        let name = peripheral.name ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "Unknown"
        if discoveredDevices.contains(where: { $0.peripheral.identifier == peripheral.identifier }) { return }
        discoveredDevices.append(DiscoveredDevice(id: peripheral.identifier, name: name, rssi: RSSI.intValue, peripheral: peripheral))
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectionState = .connected
        peripheral.discoverServices([BLEConstants.serviceUUID])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        cleanup()
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        cleanup()
    }
}

// MARK: - CBPeripheralDelegate

extension BLEManager: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services where service.uuid == BLEConstants.serviceUUID {
            peripheral.discoverCharacteristics(
                [BLEConstants.characteristicUUID, BLEConstants.controlCharacteristicUUID],
                for: service
            )
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                     didDiscoverCharacteristicsFor service: CBService,
                     error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            switch characteristic.uuid {
            case BLEConstants.characteristicUUID:
                dataCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                isReceivingData = true
            case BLEConstants.controlCharacteristicUUID:
                controlCharacteristic = characteristic
            default:
                break
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                     didUpdateValueFor characteristic: CBCharacteristic,
                     error: Error?) {//iOS auto-calls this whenever the ESP32 sends a notify()
        guard error == nil, //Bouncer that drops the packet if there's an error, wrong channel, or missing bytes
              characteristic.uuid == BLEConstants.characteristicUUID, //update comes form right data channel, ADC channel
              let data = characteristic.value else { return }//pull bytes out of the characteristic and assign them to local constant data

        var parsed: Double? //A maybe-box that will hold the number once we decode it — starts empty.

        if let rawString = String(data: data, encoding: .utf8) { //Try to read the raw bytes as UTF-8 text.
            parsed = Double(rawString.trimmingCharacters(in: .whitespacesAndNewlines)) //Trim whitespace, then convert text like "2048" → 2048.0.
        } else if data.count == 4 { //Fallback path for 4-byte binary float packets (our firmware never sends this).
            let floatVal = data.withUnsafeBytes { $0.load(as: Float.self) } //Reinterpret 4 raw bytes as a C-style Float.
            parsed = Double(floatVal) 
        }

        guard let value = parsed else { return } //If decoding failed, drop the packet; otherwise unwrap the maybe-box into a real Double.

        DispatchQueue.main.async { [weak self] in //Hop from the BLE background thread onto the main thread so it's legal to touch UI.
            self?.currentForce = value //Overwrite the live-reading variable; SwiftUI auto-refreshes the on-screen number.
            self?.onDataPoint?(value) //If a listener is hooked up, fire the callback so others (like the graph) can consume the value.
        }
    }
}
