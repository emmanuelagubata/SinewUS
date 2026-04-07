// ============================================================
// ProfileView.swift — Profile & Settings tab
// ============================================================

import SwiftUI

struct ProfileView: View {
    private let bg = Color(red: 0.06, green: 0.08, blue: 0.14)
    private let cardBg = Color(red: 0.10, green: 0.12, blue: 0.20)
    private let accentTeal = Color(red: 0.15, green: 0.85, blue: 0.75)
    private let accentGreen = Color(red: 0.35, green: 0.95, blue: 0.55)
    private let accentPurple = Color(red: 0.6, green: 0.5, blue: 1.0)

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Profile")
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                        Text("Manage your account and settings")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // User card
                        userCard

                        // Device connection card
                        deviceCard

                        // Achievements card
                        achievementsCard

                        // Settings
                        settingsCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }
        }
    }

    // MARK: - User Card

    private var userCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 14) {
                // Avatar
                Circle()
                    .fill(accentTeal.opacity(0.2))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Text("--")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(accentTeal)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Guest User")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Text("Sign in to sync your data")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }

                Spacer()

                Button(action: {}) {
                    Text("Edit")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.08))
                                .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1))
                        )
                }
            }

            // Membership bar
            VStack(spacing: 8) {
                HStack {
                    Text("Membership")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("--")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [accentTeal, accentGreen],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 0, height: 6)
                    }
                }
                .frame(height: 6)

                HStack {
                    Text("No active membership")
                        .font(.system(size: 11))
                        .foregroundColor(accentTeal.opacity(0.7))
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(cardStyle)
    }

    // MARK: - Device Card

    private var deviceCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 16))
                    .foregroundColor(accentTeal)
                Text("Device Connection")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }

            HStack(spacing: 12) {
                // Device icon
                Circle()
                    .fill(accentTeal.opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 18))
                            .foregroundColor(accentTeal)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text("SinewUS Core")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Model: --")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(connectionColor)
                            .frame(width: 6, height: 6)
                        Text(connectionLabel)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(connectionColor)
                    }
                    Text("--")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
            }

            // Battery
            HStack(spacing: 8) {
                Image(systemName: "battery.100")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Text("Battery:")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                Text("--")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }

            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 13))
                    Text("Device Settings")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.04))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )
                )
            }
        }
        .padding(20)
        .background(cardStyle)
    }

    // MARK: - Achievements Card

    private var achievementsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "trophy")
                        .font(.system(size: 16))
                        .foregroundColor(accentPurple)
                    Text("Achievements")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                Spacer()
                Text("0/6 unlocked")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.06))
                    )
            }

            // Achievement placeholders
            HStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 52, height: 52)
                        .overlay(
                            Image(systemName: "lock.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.gray.opacity(0.3))
                        )
                }
                Spacer()
            }

            Text("Complete sessions to unlock achievements")
                .font(.system(size: 11))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(20)
        .background(cardStyle)
    }

    // MARK: - Settings Card

    private var settingsCard: some View {
        VStack(spacing: 0) {
            settingsRow(icon: "bell", label: "Notifications", trailing: "Off")
            Divider().background(Color.white.opacity(0.04))
            settingsRow(icon: "ruler", label: "Units", trailing: "lbs")
            Divider().background(Color.white.opacity(0.04))
            settingsRow(icon: "questionmark.circle", label: "Help & Support", trailing: nil)
            Divider().background(Color.white.opacity(0.04))
            settingsRow(icon: "info.circle", label: "About SinewUS", trailing: "v1.0")
        }
        .background(cardStyle)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func settingsRow(icon: String, label: String, trailing: String?) -> some View {
        Button(action: {}) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(accentTeal)
                    .frame(width: 24)
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
                if let trailing = trailing {
                    Text(trailing)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.gray.opacity(0.4))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
    }

    // MARK: - Helpers

    private var connectionColor: Color {
        accentGreen
    }

    private var connectionLabel: String {
        "Not Connected"
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
