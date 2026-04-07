// ============================================================
// TrendGraphView.swift — Real-time line graph with target
// and zone overlay, styled to match the dashboard
// ============================================================

import SwiftUI

struct TrendGraphView: View {
    let dataPoints: [DataPoint]
    var targetForce: Double = 85
    var accentColor: Color = .cyan
    var targetColor: Color = .yellow.opacity(0.7)
    var zoneColor: Color = .green.opacity(0.3)

    private let visiblePoints = 200

    var body: some View {
        GeometryReader { geometry in
            let points = recentPoints
            let width = geometry.size.width
            let height = geometry.size.height

            if points.count < 2 {
                // Empty state
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: "waveform.path.ecg")
                            .foregroundColor(.gray.opacity(0.4))
                        Text("Waiting for data...")
                            .font(.system(size: 13))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                let (minF, maxF) = forceRange(points)
                let range = max(maxF - minF, 1.0)

                ZStack {
                    // Zone band (±10% of target)
                    let zoneLow = normalize(targetForce * 0.9, min: minF, range: range, height: height)
                    let zoneHigh = normalize(targetForce * 1.1, min: minF, range: range, height: height)
                    Rectangle()
                        .fill(zoneColor)
                        .frame(height: max(zoneLow - zoneHigh, 0))
                        .offset(y: zoneHigh - height / 2 + (zoneLow - zoneHigh) / 2)

                    // Target line (dashed)
                    let targetY = normalize(targetForce, min: minF, range: range, height: height)
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: targetY))
                        path.addLine(to: CGPoint(x: width, y: targetY))
                    }
                    .stroke(targetColor, style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))

                    // Data line with gradient
                    let linePath = buildLinePath(points: points, width: width, height: height, minF: minF, range: range)

                    // Glow behind line
                    linePath
                        .stroke(accentColor.opacity(0.3), lineWidth: 4)
                        .blur(radius: 4)

                    // Main line
                    linePath
                        .stroke(
                            LinearGradient(
                                colors: [accentColor, accentColor.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 2.5
                        )

                    // Current value dot
                    if let last = points.last {
                        let x = width
                        let y = normalize(last.force, min: minF, range: range, height: height)
                        Circle()
                            .fill(accentColor)
                            .frame(width: 8, height: 8)
                            .shadow(color: accentColor.opacity(0.8), radius: 6)
                            .position(x: x - 4, y: y)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private func buildLinePath(points: [DataPoint], width: CGFloat, height: CGFloat, minF: Double, range: Double) -> Path {
        Path { path in
            for (index, point) in points.enumerated() {
                let x = (CGFloat(index) / CGFloat(points.count - 1)) * width
                let y = normalize(point.force, min: minF, range: range, height: height)
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
    }

    private func normalize(_ value: Double, min minF: Double, range: Double, height: CGFloat) -> CGFloat {
        let normalized = (value - minF) / range
        return height - (CGFloat(normalized) * (height - 8)) - 4
    }

    private var recentPoints: [DataPoint] {
        if dataPoints.count <= visiblePoints {
            return dataPoints
        }
        return Array(dataPoints.suffix(visiblePoints))
    }

    private func forceRange(_ points: [DataPoint]) -> (Double, Double) {
        let forces = points.map(\.force)
        var lo = forces.min() ?? 0
        var hi = forces.max() ?? 100
        // Always include target in the range
        lo = min(lo, targetForce * 0.8)
        hi = max(hi, targetForce * 1.2)
        let padding = (hi - lo) * 0.1
        return (lo - padding, hi + padding)
    }
}
