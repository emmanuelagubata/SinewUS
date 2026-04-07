// ============================================================
// BLEManager.swift — CoreBluetooth manager for scanning,
// connecting, and streaming data from the ESP32
// ============================================================

import Foundation
import CoreBluetooth

// Represents a discovered BLE device
struct DiscoveredDevice: Identifiable {
    let id: UUID
    let name: String
    let rssi: Int
    let peripheral: CBPeripheral
}

// Connection states shown in the UI
enum ConnectionState: String {
    case disconnected = "Disconnected"
    case scanning = "Scanning..."
    case connecting = "Connecting..."
    case connected = "Connected"
}

class BLEManager: NSObject, ObservableObject {

    // MARK: - Published properties (drive the UI)

    @Published var connectionState: ConnectionState = .disconnected
    @Published var discoveredDevices: [DiscoveredDevice] = []
    @Published var currentForce: Double = 0.0
    @Published var isReceivingData = false

    // Callback for each new data point (used by session recording)
    var onDataPoint: ((Double) -> Void)?

    // MARK: - Private properties

    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var dataCharacteristic: CBCharacteristic?
    private var scanTimer: Timer?

    // MARK: - Init

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: - Public methods

    /// Start scanning for BLE devices
    func startScan() {
        guard centralManager.state == .poweredOn else {
            print("BLE not powered on, state: \(centralManager.state.rawValue)")
            return
        }

        discoveredDevices = []
        connectionState = .scanning

        centralManager.scanForPeripherals(
            withServices: [BLEConstants.serviceUUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )

        // Stop scan after timeout
        scanTimer = Timer.scheduledTimer(withTimeInterval: BLEConstants.scanTimeout, repeats: false) { [weak self] _ in
            self?.stopScan()
        }
    }

    /// Stop scanning
    func stopScan() {
        centralManager.stopScan()
        scanTimer?.invalidate()
        scanTimer = nil

        if connectionState == .scanning {
            connectionState = .disconnected
        }
    }

    /// Connect to a discovered device
    func connect(to device: DiscoveredDevice) {
        stopScan()
        connectionState = .connecting
        connectedPeripheral = device.peripheral
        connectedPeripheral?.delegate = self
        centralManager.connect(device.peripheral, options: nil)
    }

    /// Disconnect from the current device
    func disconnect() {
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        cleanup()
    }

    // MARK: - Private helpers

    private func cleanup() {
        connectedPeripheral = nil
        dataCharacteristic = nil
        connectionState = .disconnected
        isReceivingData = false
    }
}

// MARK: - CBCentralManagerDelegate

extension BLEManager: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            print("BLE state: \(central.state.rawValue)")
            cleanup()
        }
    }

    func centralManager(_ central: CBCentralManager,
                         didDiscover peripheral: CBPeripheral,
                         advertisementData: [String: Any],
                         rssi RSSI: NSNumber) {

        let name = peripheral.name ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "Unknown"

        // Skip if already discovered
        if discoveredDevices.contains(where: { $0.peripheral.identifier == peripheral.identifier }) {
            return
        }

        let device = DiscoveredDevice(
            id: peripheral.identifier,
            name: name,
            rssi: RSSI.intValue,
            peripheral: peripheral
        )
        discoveredDevices.append(device)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectionState = .connected
        // Discover the service that has our data characteristic
        peripheral.discoverServices([BLEConstants.serviceUUID])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect: \(error?.localizedDescription ?? "unknown error")")
        cleanup()
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected: \(error?.localizedDescription ?? "clean disconnect")")
        cleanup()
    }
}

// MARK: - CBPeripheralDelegate

extension BLEManager: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }

        for service in services where service.uuid == BLEConstants.serviceUUID {
            peripheral.discoverCharacteristics([BLEConstants.characteristicUUID], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                     didDiscoverCharacteristicsFor service: CBService,
                     error: Error?) {
        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics where characteristic.uuid == BLEConstants.characteristicUUID {
            dataCharacteristic = characteristic
            // Subscribe to notifications — ESP32 sends data continuously
            peripheral.setNotifyValue(true, for: characteristic)
            isReceivingData = true
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                     didUpdateValueFor characteristic: CBCharacteristic,
                     error: Error?) {
        guard characteristic.uuid == BLEConstants.characteristicUUID,
              let data = characteristic.value,
              let rawString = String(data: data, encoding: .utf8),
              let value = Double(rawString.trimmingCharacters(in: .whitespacesAndNewlines))
        else { return }

        // Update on main thread since these drive the UI
        DispatchQueue.main.async { [weak self] in
            self?.currentForce = value
            self?.onDataPoint?(value)
        }
    }
}
