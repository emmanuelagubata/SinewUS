// ============================================================
// SessionManager.swift — Tracks session state and collects
// data points for the trend graph
// ============================================================

import Foundation

// A single recorded data point
struct DataPoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let force: Double
}

class SessionManager: ObservableObject {

    @Published var isRecording = false
    @Published var dataPoints: [DataPoint] = []

    // Max points to keep on the graph (last 5 minutes at ~10Hz)
    private let maxPoints = 3000

    /// Start recording session data
    func start() {
        dataPoints = []
        isRecording = true
    }

    /// Stop recording session data
    func stop() {
        isRecording = false
    }

    /// Add a new data point (called from BLEManager.onDataPoint)
    func addPoint(_ force: Double) {
        guard isRecording else { return }

        let point = DataPoint(timestamp: Date(), force: force)
        dataPoints.append(point)

        // Trim old points to keep memory bounded
        if dataPoints.count > maxPoints {
            dataPoints.removeFirst(dataPoints.count - maxPoints)
        }
    }
}
