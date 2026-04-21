// ============================================================
// TrendGraphView.swift — Real-time scrolling graph
// with time axis, pinch-to-zoom, and drag-to-inspect
// ============================================================

import SwiftUI

struct TrendGraphView: View {
    let dataPoints: [DataPoint]
    var accentColor: Color = .cyan

    // Fixed time window: graph always represents this many seconds of width
    // New data scrolls in from the right like an oscilloscope
    private let timeWindowSeconds: Double = 20

    // Zoom & pan state
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    // Drag-to-inspect state
    @State private var inspectLocation: CGPoint? = nil
    @State private var isDragging = false

    // Layout constants
    private let graphTopPadding: CGFloat = 8
    private let graphBottomPadding: CGFloat = 24 // room for time labels
    private let yLabelWidth: CGFloat = 30

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let graphHeight = height - graphBottomPadding

            if dataPoints.count < 2 {
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: "waveform.path.ecg")
                            .foregroundColor(.gray.opacity(0.4))
                        Text("Tap Start Session to begin...")
                            .font(.system(size: 13))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                let (minF, maxF) = stableForceRange
                let range = max(maxF - minF, 1.0)
                let sessionStart = dataPoints.first!.timestamp
                let elapsed = dataPoints.last!.timestamp.timeIntervalSince(sessionStart)
                // The time window shown: always at least timeWindowSeconds wide
                let windowEnd = max(elapsed, timeWindowSeconds)
                let windowStart = windowEnd - timeWindowSeconds

                ZStack(alignment: .topLeading) {
                    // Grid lines (horizontal)
                    VStack(spacing: 0) {
                        ForEach(0..<5, id: \.self) { _ in
                            Divider().background(Color.white.opacity(0.04))
                            Spacer()
                        }
                    }
                    .frame(height: graphHeight)

                    // Y-axis labels
                    VStack {
                        Text(String(format: "%.0f", maxF))
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.gray.opacity(0.5))
                        Spacer()
                        Text(String(format: "%.0f", (maxF + minF) / 2))
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.gray.opacity(0.5))
                        Spacer()
                        Text(String(format: "%.0f", minF))
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    .frame(height: graphHeight, alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Time axis labels (X-axis)
                    let tickInterval: Double = 10 // seconds between labels
                    let firstTick = ceil(windowStart / tickInterval) * tickInterval
                    VStack {
                        Spacer()
                        ZStack(alignment: .leading) {
                            ForEach(Array(stride(from: firstTick, through: windowEnd, by: tickInterval)), id: \.self) { tick in
                                let xFrac = (tick - windowStart) / timeWindowSeconds
                                if xFrac >= 0 && xFrac <= 1 {
                                    Text(formatTime(tick))
                                        .font(.system(size: 9, design: .monospaced))
                                        .foregroundColor(.gray.opacity(0.5))
                                        .position(x: CGFloat(xFrac) * width, y: graphHeight + 12)
                                }
                            }
                        }
                    }

                    // Vertical grid lines at tick marks
                    ForEach(Array(stride(from: firstTick, through: windowEnd, by: tickInterval)), id: \.self) { tick in
                        let xFrac = (tick - windowStart) / timeWindowSeconds
                        if xFrac >= 0 && xFrac <= 1 {
                            Path { path in
                                let x = CGFloat(xFrac) * width
                                path.move(to: CGPoint(x: x, y: 0))
                                path.addLine(to: CGPoint(x: x, y: graphHeight))
                            }
                            .stroke(Color.white.opacity(0.04), lineWidth: 1)
                        }
                    }

                    // Data line
                    let visiblePoints = dataPoints.filter { pt in
                        let t = pt.timestamp.timeIntervalSince(sessionStart)
                        return t >= windowStart && t <= windowEnd
                    }

                    if visiblePoints.count >= 2 {
                        let linePath = buildLinePath(
                            points: visiblePoints,
                            sessionStart: sessionStart,
                            windowStart: windowStart,
                            width: width,
                            graphHeight: graphHeight,
                            minF: minF,
                            range: range
                        )

                        Group {
                            // Glow
                            linePath
                                .stroke(accentColor.opacity(0.3), lineWidth: 4)
                                .blur(radius: 3)

                            // Main line
                            linePath
                                .stroke(accentColor, lineWidth: 2.5)

                            // Current value dot (latest point)
                            if let last = visiblePoints.last {
                                let t = last.timestamp.timeIntervalSince(sessionStart)
                                let xFrac = (t - windowStart) / timeWindowSeconds
                                let x = CGFloat(xFrac) * width
                                let y = normalizeY(last.force, min: minF, range: range, height: graphHeight)
                                Circle()
                                    .fill(accentColor)
                                    .frame(width: 8, height: 8)
                                    .shadow(color: accentColor.opacity(0.8), radius: 6)
                                    .position(x: x, y: y)
                            }
                        }
                        .scaleEffect(scale, anchor: .center)
                        .offset(offset)
                    }

                    // Drag-to-inspect overlay
                    if isDragging, let loc = inspectLocation {
                        inspectOverlay(
                            at: loc,
                            sessionStart: sessionStart,
                            windowStart: windowStart,
                            width: width,
                            graphHeight: graphHeight,
                            minF: minF,
                            range: range
                        )
                    }
                }
                .clipped()
                .contentShape(Rectangle())
                .gesture(inspectGesture)
                .gesture(pinchGesture)
                .simultaneousGesture(doubleTapGesture)
            }
        }
    }

    // MARK: - Inspect overlay (crosshair + tooltip)

    private func inspectOverlay(
        at location: CGPoint,
        sessionStart: Date,
        windowStart: Double,
        width: CGFloat,
        graphHeight: CGFloat,
        minF: Double,
        range: Double
    ) -> some View {
        let xFrac = Double(location.x / width)
        let timeAtX = windowStart + xFrac * timeWindowSeconds

        // Find closest data point
        let closest = dataPoints.min(by: { a, b in
            abs(a.timestamp.timeIntervalSince(sessionStart) - timeAtX) <
            abs(b.timestamp.timeIntervalSince(sessionStart) - timeAtX)
        })

        let pointTime = closest.map { $0.timestamp.timeIntervalSince(sessionStart) } ?? timeAtX
        let pointForce = closest?.force ?? 0
        let pointX = CGFloat((pointTime - windowStart) / timeWindowSeconds) * width
        let pointY = normalizeY(pointForce, min: minF, range: range, height: graphHeight)

        return ZStack {
            // Vertical crosshair line
            Path { path in
                path.move(to: CGPoint(x: pointX, y: 0))
                path.addLine(to: CGPoint(x: pointX, y: graphHeight))
            }
            .stroke(Color.white.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))

            // Horizontal crosshair line
            Path { path in
                path.move(to: CGPoint(x: 0, y: pointY))
                path.addLine(to: CGPoint(x: width, y: pointY))
            }
            .stroke(Color.white.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))

            // Dot at intersection
            Circle()
                .fill(Color.white)
                .frame(width: 8, height: 8)
                .shadow(color: accentColor, radius: 4)
                .position(x: pointX, y: pointY)

            // Tooltip
            let tooltipX = pointX < width / 2 ? pointX + 70 : pointX - 70
            VStack(spacing: 3) {
                Text(String(format: "%.0f ADC", pointForce))
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                Text(formatTime(pointTime))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.12, green: 0.14, blue: 0.22))
                    .shadow(color: .black.opacity(0.4), radius: 4)
            )
            .position(x: tooltipX, y: max(pointY - 30, 20))
        }
    }

    // MARK: - Gestures

    private var inspectGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if scale <= 1.0 {
                    // At default zoom, drag = inspect
                    isDragging = true
                    inspectLocation = value.location
                } else {
                    // While zoomed in, drag = pan
                    isDragging = false
                    offset = CGSize(
                        width: lastOffset.width + value.translation.width,
                        height: lastOffset.height + value.translation.height
                    )
                }
            }
            .onEnded { _ in
                isDragging = false
                inspectLocation = nil
                if scale > 1.0 {
                    lastOffset = offset
                }
            }
    }

    private var pinchGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let newScale = lastScale * value
                scale = min(max(newScale, 1.0), 10.0)
            }
            .onEnded { _ in
                lastScale = scale
                if scale <= 1.0 {
                    withAnimation(.easeOut(duration: 0.2)) {
                        offset = .zero
                        lastOffset = .zero
                    }
                }
            }
    }

    private var doubleTapGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation(.easeOut(duration: 0.25)) {
                    scale = 1.0
                    lastScale = 1.0
                    offset = .zero
                    lastOffset = .zero
                }
            }
    }

    // MARK: - Drawing

    private func buildLinePath(
        points: [DataPoint],
        sessionStart: Date,
        windowStart: Double,
        width: CGFloat,
        graphHeight: CGFloat,
        minF: Double,
        range: Double
    ) -> Path {
        Path { path in
            for (index, point) in points.enumerated() {
                let t = point.timestamp.timeIntervalSince(sessionStart)
                let xFrac = (t - windowStart) / timeWindowSeconds
                let x = CGFloat(xFrac) * width
                let y = normalizeY(point.force, min: minF, range: range, height: graphHeight)
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
    }

    private func normalizeY(_ value: Double, min minF: Double, range: Double, height: CGFloat) -> CGFloat {
        let normalized = CGFloat((value - minF) / range)
        let clamped = Swift.min(Swift.max(normalized, 0), 1)
        let padding: CGFloat = 8
        return height - padding - (clamped * (height - padding * 2))
    }

    // MARK: - Y-axis range

    /// Fixed 0–255 range for 8-bit ADC.
    /// Change the ceiling here if you switch back to 12-bit (0–4095).
    private var stableForceRange: (Double, Double) {
        return (0, 260)
    }

    // MARK: - Time formatting

    /// Formats seconds elapsed as "0s", "10s", "1:00", "1:30", etc.
    private func formatTime(_ seconds: Double) -> String {
        let s = max(seconds, 0)
        if s < 60 {
            return String(format: "%.0fs", s)
        } else {
            let mins = Int(s) / 60
            let secs = Int(s) % 60
            return String(format: "%d:%02d", mins, secs)
        }
    }
}
