// ============================================================
// TrendGraphView.swift — Simple real-time line graph
// Shows the last N data points as a trend line
// ============================================================

import SwiftUI

struct TrendGraphView: View {
    let dataPoints: [DataPoint]

    // How many points to show on screen at once
    private let visiblePoints = 200

    var body: some View {
        GeometryReader { geometry in
            let points = recentPoints
            let width = geometry.size.width
            let height = geometry.size.height

            if points.count < 2 {
                // Not enough data yet
                VStack {
                    Spacer()
                    Text("Waiting for data...")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                let (minForce, maxForce) = forceRange(points)
                let range = max(maxForce - minForce, 1.0) // avoid division by zero

                ZStack(alignment: .topLeading) {
                    // Y-axis labels
                    VStack {
                        Text(String(format: "%.0f", maxForce))
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                        Spacer()
                        Text(String(format: "%.0f", minForce))
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                    }
                    .frame(width: 40, height: height)

                    // Line graph
                    Path { path in
                        let graphWidth = width - 44
                        let graphX: CGFloat = 44

                        for (index, point) in points.enumerated() {
                            let x = graphX + (CGFloat(index) / CGFloat(points.count - 1)) * graphWidth
                            let normalized = (point.force - minForce) / range
                            let y = height - (CGFloat(normalized) * (height - 8)) - 4

                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(Color.blue, lineWidth: 2)
                }
            }
        }
    }

    // Get the most recent points to display
    private var recentPoints: [DataPoint] {
        if dataPoints.count <= visiblePoints {
            return dataPoints
        }
        return Array(dataPoints.suffix(visiblePoints))
    }

    // Calculate min/max with a small padding
    private func forceRange(_ points: [DataPoint]) -> (Double, Double) {
        let forces = points.map(\.force)
        let min = forces.min() ?? 0
        let max = forces.max() ?? 1
        let padding = (max - min) * 0.1
        return (min - padding, max + padding)
    }
}
