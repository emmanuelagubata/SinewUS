// ============================================================
// ConnectView.swift — Page 1: Branded landing + BLE connect
// ============================================================

import SwiftUI

struct ConnectView: View {
    @ObservedObject var bleManager: BLEManager
    var onConnected: () -> Void

    // Pulsing glow animation
    @State private var glowPhase = false

    // Theme colors
    private let bg = Color(red: 0.06, green: 0.08, blue: 0.14)
    private let cardBg = Color(red: 0.10, green: 0.12, blue: 0.20)
    private let accentTeal = Color(red: 0.15, green: 0.85, blue: 0.75)
    private let accentGreen = Color(red: 0.35, green: 0.95, blue: 0.55)

    var body: some View {
        ZStack {
            // Background
            bg.ignoresSafeArea()

            VStack(spacing: 0) {

                Spacer().frame(height: 60)

                // ── Logo & Branding ──
                logoSection

                Spacer().frame(height: 12)

                // ── Feature bullets ──
                featureBullets
                    .padding(.horizontal, 40)

                Spacer().frame(height: 32)

                // ── Connection Card ──
                connectionCard
                    .padding(.horizontal, 24)

                Spacer()

                // ── Footer ──
                Text("Requires Bluetooth-enabled SinewUS device")
                    .font(.system(size: 12))
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(.bottom, 32)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glowPhase = true
            }
        }
        .onChange(of: bleManager.connectionState) { newState in
            if newState == .connected {
                // Short delay so user sees "Connected" before transition
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    onConnected()
                }
            }
        }
    }

    // MARK: - Logo Section

    private var logoSection: some View {
        VStack(spacing: 8) {
            // App icon
            Image("AppIcon-Display")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 90, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: accentTeal.opacity(glowPhase ? 0.5 : 0.2), radius: 20)
                .padding(.bottom, 8)

            Text("SinewUS")
                .font(.system(size: 38, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            Text("Improve Performance. Prevent Injury.\nAccelerate Recovery.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }

    // MARK: - Feature Bullets

    private var featureBullets: some View {
        VStack(alignment: .leading, spacing: 12) {
            bulletRow(color: accentTeal, text: "Real-time force measurement")
            bulletRow(color: accentGreen, text: "Science-backed training programs")
            bulletRow(color: Color(red: 0.6, green: 0.5, blue: 1.0), text: "Performance analytics")
        }
        .padding(.vertical, 16)
    }

    private func bulletRow(color: Color, text: String) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .shadow(color: color.opacity(0.6), radius: 4)
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
        }
    }

    // MARK: - Connection Card

    private var connectionCard: some View {
        VStack(spacing: 16) {

            // Status row
            HStack(spacing: 8) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 10, height: 10)
                    .shadow(color: statusColor.opacity(0.7), radius: 6)
                Text(bleManager.connectionState.rawValue)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(statusColor)
                Spacer()
            }

            // Scan button
            Button(action: { bleManager.startScan() }) {
                HStack(spacing: 8) {
                    if bleManager.connectionState == .scanning {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.8)
                    }
                    Text(bleManager.connectionState == .scanning ? "Scanning..." : "Scan for Devices")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
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
                .shadow(color: accentTeal.opacity(0.4), radius: 8, y: 4)
            }
            .disabled(bleManager.connectionState == .scanning || bleManager.connectionState == .connecting)
            .opacity(bleManager.connectionState == .scanning ? 0.7 : 1.0)

            // Device list or empty state
            if bleManager.discoveredDevices.isEmpty {
                if bleManager.connectionState == .scanning {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(.gray)
                            .scaleEffect(0.7)
                        Text("Searching for SinewUS devices...")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 8)
                } else {
                    Text("Tap Scan to find your SinewUS device")
                        .font(.system(size: 13))
                        .foregroundColor(.gray.opacity(0.7))
                        .padding(.vertical, 8)
                }
            } else {
                VStack(spacing: 8) {
                    ForEach(bleManager.discoveredDevices) { device in
                        deviceRow(device)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private func deviceRow(_ device: DiscoveredDevice) -> some View {
        Button(action: { bleManager.connect(to: device) }) {
            HStack(spacing: 12) {
                // BLE icon
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 16))
                    .foregroundColor(accentTeal)
                    .frame(width: 36, height: 36)
                    .background(accentTeal.opacity(0.15))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(device.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Signal: \(device.rssi) dBm")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }

                Spacer()

                if bleManager.connectionState == .connecting {
                    ProgressView()
                        .tint(accentTeal)
                        .scaleEffect(0.8)
                } else {
                    Text("Connect")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(accentTeal)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(accentTeal.opacity(0.15))
                        .cornerRadius(8)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.04))
            )
        }
    }

    // MARK: - Helpers

    private var statusColor: Color {
        switch bleManager.connectionState {
        case .disconnected: return .red
        case .scanning: return .yellow
        case .connecting: return .orange
        case .connected: return accentGreen
        }
    }
}
