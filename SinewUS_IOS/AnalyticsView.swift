// ============================================================
// AnalyticsView.swift — Analytics & History tab
// ============================================================

import SwiftUI

struct AnalyticsView: View {
    @State private var selectedFilter = "Weekly Force"

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
                        Text("Analytics")
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                        Text("Track your progress")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button(action: {}) {
                        HStack(spacing: 6) {
                            Image(systemName: "line.3.horizontal.decrease")
                                .font(.system(size: 14))
                            Text("Filter")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.08))
                                .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1))
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Stat cards row
                        statCardsRow

                        // Monthly trends card
                        trendsCard

                        // Filter toggle
                        filterToggle

                        // Session history (empty)
                        sessionHistoryCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }
        }
    }

    // MARK: - Stat Cards

    private var statCardsRow: some View {
        HStack(spacing: 10) {
            statCard(
                icon: "arrow.up.right",
                iconColor: accentGreen,
                value: "--",
                label: "Max Force\n(lbs)",
                change: nil
            )
            statCard(
                icon: "clock",
                iconColor: accentTeal,
                value: "--",
                label: "This Week",
                change: nil
            )
            statCard(
                icon: "scope",
                iconColor: accentPurple,
                value: "--",
                label: "Sessions",
                change: nil
            )
        }
    }

    private func statCard(icon: String, iconColor: Color, value: String, label: String, change: String?) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            if let change = change {
                HStack(spacing: 2) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 9))
                    Text(change)
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(accentGreen)
            } else {
                Text(" ")
                    .font(.system(size: 11))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    // MARK: - Monthly Trends

    private var trendsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 16))
                        .foregroundColor(accentTeal)
                    Text("Monthly Trends")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                Spacer()
                Text("4 Months")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.06))
                    )
            }

            // Empty chart area
            ZStack {
                // Grid lines
                VStack(spacing: 0) {
                    ForEach(0..<4, id: \.self) { _ in
                        Divider()
                            .background(Color.white.opacity(0.04))
                        Spacer()
                    }
                }

                // Empty state
                VStack(spacing: 8) {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.system(size: 24))
                        .foregroundColor(.gray.opacity(0.3))
                    Text("No data yet")
                        .font(.system(size: 12))
                        .foregroundColor(.gray.opacity(0.4))
                }
            }
            .frame(height: 160)

            // Month labels
            HStack {
                Spacer()
                Text("Feb").font(.system(size: 11)).foregroundColor(.gray)
                Spacer()
                Text("Mar").font(.system(size: 11)).foregroundColor(.gray)
                Spacer()
                Text("Apr").font(.system(size: 11)).foregroundColor(.gray)
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    // MARK: - Filter Toggle

    private var filterToggle: some View {
        HStack(spacing: 0) {
            ForEach(["Weekly Force", "Session Time"], id: \.self) { option in
                Button(action: { selectedFilter = option }) {
                    Text(option)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(selectedFilter == option ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedFilter == option ? Color.white.opacity(0.1) : Color.clear)
                        )
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    // MARK: - Session History

    private var sessionHistoryCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Session History")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }

            VStack(spacing: 8) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 28))
                    .foregroundColor(.gray.opacity(0.3))
                Text("No sessions recorded yet")
                    .font(.system(size: 13))
                    .foregroundColor(.gray.opacity(0.5))
                Text("Complete a session to see your history")
                    .font(.system(size: 11))
                    .foregroundColor(.gray.opacity(0.3))
            }
            .padding(.vertical, 24)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}
