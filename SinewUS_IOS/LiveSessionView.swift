// ============================================================
// LiveSessionView.swift — Shows live force reading, trend
// graph, and session start/stop controls
// ============================================================

import SwiftUI

struct LiveSessionView: View {
    @ObservedObject var bleManager: BLEManager
    @ObservedObject var sessionManager: SessionManager
    var onDisconnect: () -> Void

    var body: some View {
        VStack(spacing: 20) {

            // Connection status bar
            HStack(spacing: 8) {
                Circle()
                    .fill(bleManager.connectionState == .connected ? Color.green : Color.red)
                    .frame(width: 10, height: 10)
                Text(bleManager.connectionState.rawValue)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Button("Disconnect") {
                    sessionManager.stop()
                    bleManager.disconnect()
                    onDisconnect()
                }
                .font(.caption.weight(.bold))
                .foregroundColor(.red)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            // Current force reading — big and readable
            VStack(spacing: 4) {
                Text(String(format: "%.1f", bleManager.currentForce))
                    .font(.system(size: 72, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                Text("grams")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 16)

            // Session status
            if sessionManager.isRecording {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                    Text("Recording  \u{2022}  \(sessionManager.dataPoints.count) points")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            // Trend graph
            TrendGraphView(dataPoints: sessionManager.dataPoints)
                .frame(height: 200)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(white: 0.1))
                        .padding(.horizontal, 12)
                )

            Spacer()

            // Start / Stop session buttons
            if sessionManager.isRecording {
                Button(action: { sessionManager.stop() }) {
                    Text("Stop Session")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 32)
            } else {
                Button(action: { sessionManager.start() }) {
                    Text("Start Session")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 32)
            }

            Spacer().frame(height: 24)
        }
        .background(Color.black)
        // Wire BLE data into session recording
        .onAppear {
            bleManager.onDataPoint = { [weak sessionManager] value in
                sessionManager?.addPoint(value)
            }
        }
        .onDisappear {
            bleManager.onDataPoint = nil
        }
    }
}
