// ============================================================
// LiveSessionView.swift — Page 2: Live force dashboard
// ============================================================

import SwiftUI

struct LiveSessionView: View {
    @ObservedObject var bleManager: BLEManager
    @ObservedObject var sessionManager: SessionManager
    var onDisconnect: () -> Void

    @State private var showFullscreenGraph = false

    private let bg = Color(red: 0.06, green: 0.08, blue: 0.14)
    private let cardBg = Color(red: 0.10, green: 0.12, blue: 0.20)
    private let accentTeal = Color(red: 0.15, green: 0.85, blue: 0.75)
    private let accentGreen = Color(red: 0.35, green: 0.95, blue: 0.55)

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        forceCard
                        graphCard
                        targetAreaCard
                        sessionButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }
        }
        .fullScreenCover(isPresented: $showFullscreenGraph) {
            fullscreenGraphOverlay
        }
        .onAppear {
            bleManager.onDataPoint = { [weak sessionManager] value in
                sessionManager?.addPoint(value)
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
            .background(Capsule().fill(Color.white.opacity(0.06)))
        }
    }

    // MARK: - Force Card

    private var forceCard: some View {
        VStack(spacing: 8) {
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(String(format: "%.1f", bleManager.currentForce))
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())
                    .animation(.easeOut(duration: 0.15), value: bleManager.currentForce)
                Text("ADC")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.bottom, 6)
            }
        }
        .padding(20)
        .background(cardStyle)
    }

    // MARK: - Graph Card

    private var graphCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 4) {
                    Circle().fill(accentTeal).frame(width: 6, height: 6)
                    Text("Force (N)")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                Spacer()
                if sessionManager.isRecording {
                    HStack(spacing: 4) {
                        Circle().fill(Color.red).frame(width: 6, height: 6)
                        Text("Recording")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.red)
                    }
                }
                Text("Live")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(accentGreen)

                // Expand button
                Button(action: { showFullscreenGraph = true }) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                        .padding(6)
                        .background(Circle().fill(Color.white.opacity(0.08)))
                }
            }

            TrendGraphView(
                dataPoints: sessionManager.dataPoints,
                accentColor: accentTeal
            )
            .frame(height: 180)
            .onTapGesture { showFullscreenGraph = true }

            if sessionManager.isRecording {
                Text("\(sessionManager.dataPoints.count) data points")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
        }
        .padding(20)
        .background(cardStyle)
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
                    Button(action: { sessionManager.selectedArea = area }) {
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
                Button(action: {
                    bleManager.sendCommand("STOP")
                    sessionManager.stop()
                }) {
                    Text("Stop Session")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(14)
                }
            } else {
                Button(action: {
                    bleManager.sendCommand("START")
                    sessionManager.start()
                }) {
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
                bleManager.sendCommand("STOP")
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

    // MARK: - Fullscreen Graph Overlay

    private var fullscreenGraphOverlay: some View {
        ZStack {
            bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header bar
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Graph Detail")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("Pinch to zoom, drag to pan, double-tap to reset")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                    Spacer()

                    // Live ADC readout
                    Text(String(format: "%.0f", bleManager.currentForce))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(accentTeal)
                        .padding(.trailing, 8)

                    Button(action: { showFullscreenGraph = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // Recording indicator
                if sessionManager.isRecording {
                    HStack(spacing: 6) {
                        Circle().fill(Color.red).frame(width: 6, height: 6)
                        Text("Recording — \(sessionManager.dataPoints.count) pts")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.red)
                    }
                    .padding(.bottom, 8)
                }

                // Full-size graph
                TrendGraphView(
                    dataPoints: sessionManager.dataPoints,
                    accentColor: accentTeal
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
    }

    private var cardStyle: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(cardBg)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
    }
}
