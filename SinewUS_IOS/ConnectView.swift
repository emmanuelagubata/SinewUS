// ============================================================
// ConnectView.swift — Scan for BLE devices and connect
// ============================================================

import SwiftUI

struct ConnectView: View {
    @ObservedObject var bleManager: BLEManager
    var onConnected: () -> Void

    var body: some View {
        VStack(spacing: 24) {

            Spacer()

            // App title
            Text("SinewUS")
                .font(.system(size: 42, weight: .heavy))
                .foregroundColor(.white)

            Text("Wearable Tendon Load Monitor")
                .font(.subheadline)
                .foregroundColor(.gray)

            // Connection status indicator
            HStack(spacing: 8) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 10, height: 10)
                Text(bleManager.connectionState.rawValue)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.top, 8)

            // Scan button
            Button(action: { bleManager.startScan() }) {
                Text(bleManager.connectionState == .scanning ? "Scanning..." : "Scan for Devices")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(14)
            }
            .disabled(bleManager.connectionState == .scanning || bleManager.connectionState == .connecting)
            .opacity(bleManager.connectionState == .scanning ? 0.6 : 1.0)
            .padding(.horizontal, 32)

            // Device list
            if bleManager.discoveredDevices.isEmpty && bleManager.connectionState != .scanning {
                Text("No devices found. Tap Scan to search.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 16)
            }

            List(bleManager.discoveredDevices) { device in
                Button(action: { bleManager.connect(to: device) }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(device.name)
                                .font(.body.weight(.semibold))
                                .foregroundColor(.white)
                            Text("Signal: \(device.rssi) dBm")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        if bleManager.connectionState == .connecting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Connect")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color(white: 0.15))
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)

            Spacer()
        }
        .background(Color.black)
        // Navigate to live session when connected
        .onChange(of: bleManager.connectionState) { newState in
            if newState == .connected {
                onConnected()
            }
        }
    }

    private var statusColor: Color {
        switch bleManager.connectionState {
        case .disconnected: return .red
        case .scanning: return .yellow
        case .connecting: return .orange
        case .connected: return .green
        }
    }
}
