// ============================================================
// SessionManager.swift — Tracks session state, target force,
// selected body area, and collects data points
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
    @Published var targetForce: Double = 85 {
        didSet { updateMaxScale() }
    }
    @Published var selectedArea: String = "Achilles/Calf"
    @Published var maxForceScale: Double = 100

    static let targetAreas = ["Achilles/Calf", "Knee", "Shoulder", "Elbow"]

    private func updateMaxScale() {
        // Scale the bar so target sits around 80% of the way
        maxForceScale = max(ceil(targetForce * 1.25 / 10) * 10, 50)
    }

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

        let point = DataPoint(timestamp: Date(), force: force)
        dataPoints.append(point)

        if dataPoints.count > maxPoints {
            dataPoints.removeFirst(dataPoints.count - maxPoints)
        }
    }
}
