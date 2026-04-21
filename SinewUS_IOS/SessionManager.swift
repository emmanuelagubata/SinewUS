// ============================================================
// SessionManager.swift — Tracks session state and collects
// data points for the trend graph
// ============================================================

import Foundation

struct DataPoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let force: Double
}

class SessionManager: ObservableObject {

    @Published var isRecording = false
    @Published var dataPoints: [DataPoint] = []
    @Published var selectedArea: String = "Achilles/Calf"

    static let targetAreas = ["Achilles/Calf", "Knee", "Shoulder", "Elbow"]

    private let maxPoints = 3000

    func start() {
        dataPoints = []
        isRecording = true
    }

    func stop() {
        isRecording = false
    }

    func addPoint(_ force: Double) {
        guard isRecording else { return }
        dataPoints.append(DataPoint(timestamp: Date(), force: force))
        if dataPoints.count > maxPoints {
            dataPoints.removeFirst(dataPoints.count - maxPoints)
        }
    }
}
