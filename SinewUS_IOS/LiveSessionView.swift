// ============================================================
// LiveSessionView.swift — Page 2: Live force dashboard
// ============================================================

import SwiftUI

struct LiveSessionView: View {
    @ObservedObject var bleManager: BLEManager
    @ObservedObject var sessionManager: SessionManager
    var onDisconnect: () -> Void

    @State private var showTargetInput = false
    @State private var targetText = ""

    // Theme colors
    private let bg = Color(red: 0.06, green: 0.08, blue: 0.14)
    private let cardBg = Color(red: 0.10, green: 0.12, blue: 0.20)
    private let accentTeal = Color(red: 0.15, green: 0.85, blue: 0.75)
    private let accentGreen = Color(red: 0.35, green: 0.95, blue: 0.55)

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Top bar ──
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // ── Force reading card ──
                        forceCard

                        // ── Trend graph card ──
                        graphCard

                        // ── Target area card ──
                        targetAreaCard

                        // ── Session button ──
                        sessionButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
        }
        .onAppear {
            bleManager.onDataPoint = { [weak sessionManager] value in
                sessionManager?.addPoint(value)
            }
            // Auto-start recording
            if !sessionManager.isRecording {
                sessionManager.start()
            }
        }
        .onDisappear {
            bleManager.onDataPoint = nil
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("SinewUS")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                Text("Real-time isometric monitoring")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            Spacer()
            // Connection badge
            HStack(spacing: 6) {
                Circle()
                    .fill(bleManager.connectionState == .connected ? accentGreen : .red)
                    .frame(width: 8, height: 8)
                    .shadow(color: (bleManager.connectionState == .connected ? accentGreen : .red).opacity(0.7), radius: 4)
                Text(bleManager.connectionState == .connected ? "Connected" : "Disconnected")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(bleManager.connectionState == .connected ? accentGreen : .red)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.06))
            )
        }
    }

    // MARK: - Force Card

    private var forceCard: some View {
        VStack(spacing: 12) {
            // Big force number
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(String(format: "%.1f", bleManager.currentForce))
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())
                    .animation(.easeOut(duration: 0.15), value: bleManager.currentForce)
                Text("lbs")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.bottom, 6)
            }

            // Progress bar
            forceProgressBar

            // Target label — tap to edit
            HStack {
                Text("0")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                Spacer()
                Button(action: {
                    targetText = "\(Int(sessionManager.targetForce))"
                    showTargetInput = true
                }) {
                    HStack(spacing: 4) {
                        Text("Target: \(Int(sessionManager.targetForce)) lbs")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(accentTeal)
                        Image(systemName: "pencil")
                            .font(.system(size: 10))
                            .foregroundColor(accentTeal.opacity(0.7))
                    }
                }
                Spacer()
                Text("\(Int(sessionManager.maxForceScale))")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
        }
        .padding(20)
        .background(cardStyle)
        .sheet(isPresented: $showTargetInput) {
            targetInputSheet
        }
    }

    private var forceProgressBar: some View {
        GeometryReader { geo in
            let maxForce = sessionManager.maxForceScale
            let progress = min(bleManager.currentForce / maxForce, 1.0)
            let targetProgress = min(sessionManager.targetForce / maxForce, 1.0)

            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 12)

                // Fill
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [accentTeal, accentGreen],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(geo.size.width * CGFloat(progress), 0), height: 12)
                    .animation(.easeOut(duration: 0.15), value: progress)

                // Target marker
                Rectangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 2, height: 18)
                    .offset(x: geo.size.width * CGFloat(targetProgress) - 1)
            }
        }
        .frame(height: 18)
    }

    // MARK: - Graph Card

    private var graphCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Legend
                HStack(spacing: 16) {
                    legendDot(color: accentTeal, label: "Current")
                    legendDash(color: .yellow.opacity(0.7), label: "Target")
                    legendDash(color: accentGreen.opacity(0.5), label: "Zone")
                }
                Spacer()
                Text("Live")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(accentGreen)
            }

            TrendGraphView(
                dataPoints: sessionManager.dataPoints,
                targetForce: sessionManager.targetForce,
                accentColor: accentTeal,
                targetColor: .yellow.opacity(0.7),
                zoneColor: accentGreen.opacity(0.3)
            )
            .frame(height: 160)

            // Recording indicator
            if sessionManager.isRecording {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 6, height: 6)
                    Text("\(sessionManager.dataPoints.count) data points")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(20)
        .background(cardStyle)
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label).font(.system(size: 11)).foregroundColor(.gray)
        }
    }

    private func legendDash(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 1)
                .fill(color)
                .frame(width: 12, height: 2)
            Text(label).font(.system(size: 11)).foregroundColor(.gray)
        }
    }

    // MARK: - Target Area Card

    private var targetAreaCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "scope")
                    .font(.system(size: 16))
                    .foregroundColor(accentTeal)
                Text("Target Area")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ], spacing: 10) {
                ForEach(SessionManager.targetAreas, id: \.self) { area in
                    Button(action: {
                        sessionManager.selectedArea = area
                    }) {
                        Text(area)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(sessionManager.selectedArea == area ? .black : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(sessionManager.selectedArea == area
                                          ? accentTeal
                                          : Color.white.opacity(0.06))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(sessionManager.selectedArea == area
                                            ? Color.clear
                                            : Color.white.opacity(0.08), lineWidth: 1)
                            )
                    }
                }
            }
        }
        .padding(20)
        .background(cardStyle)
    }

    // MARK: - Session Button

    private var sessionButton: some View {
        VStack(spacing: 12) {
            if sessionManager.isRecording {
                Button(action: { sessionManager.stop() }) {
                    Text("Stop Session")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(14)
                }
            } else {
                Button(action: { sessionManager.start() }) {
                    Text("Start Session")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [accentTeal, accentGreen],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: accentTeal.opacity(0.3), radius: 8, y: 4)
                }
            }

            Button(action: {
                sessionManager.stop()
                bleManager.disconnect()
                onDisconnect()
            }) {
                Text("Disconnect")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.red.opacity(0.8))
            }
        }
    }

    // MARK: - Target Input Sheet

    private var targetInputSheet: some View {
        ZStack {
            bg.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer().frame(height: 20)

                Text("Set Target Weight")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                Text("Enter your target force in lbs")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                TextField("", text: $targetText)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(cardBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(accentTeal.opacity(0.4), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 48)

                Text("lbs")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)

                Button(action: {
                    if let value = Double(targetText), value > 0 {
                        sessionManager.targetForce = value
                    }
                    showTargetInput = false
                }) {
                    Text("Set Target")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [accentTeal, accentGreen],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                }
                .padding(.horizontal, 32)

                Button("Cancel") {
                    showTargetInput = false
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)

                Spacer()
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Card Style

    private var cardStyle: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(cardBg)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
    }
}
