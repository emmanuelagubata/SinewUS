// ============================================================
// TrainingView.swift — Training Programs tab
// ============================================================

import SwiftUI

struct TrainingView: View {
    @State private var selectedArea: String? = nil

    private let bg = Color(red: 0.06, green: 0.08, blue: 0.14)
    private let cardBg = Color(red: 0.10, green: 0.12, blue: 0.20)
    private let accentTeal = Color(red: 0.15, green: 0.85, blue: 0.75)
    private let accentGreen = Color(red: 0.35, green: 0.95, blue: 0.55)
    private let accentOrange = Color(red: 1.0, green: 0.55, blue: 0.35)
    private let accentPurple = Color(red: 0.6, green: 0.5, blue: 1.0)

    private let areas = ["Achilles/Calf", "Knee", "Shoulder", "Elbow"]

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Training Programs")
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                        Text("Structured isometric routines")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Featured program card
                        featuredCard

                        // Target areas
                        targetAreasCard

                        // All programs
                        allProgramsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }
        }
    }

    // MARK: - Featured Card

    private var featuredCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Featured")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(accentOrange))

                Spacer()

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2")
                            .font(.system(size: 11))
                        Text("--")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.gray)

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.yellow)
                        Text("--")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            }

            Text("Full-Body Diagnostic")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            Text("Baseline diagnostics program to identify current areas of weakness")
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .lineSpacing(2)

            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    Text("30 min")
                        .font(.system(size: 12))
                }
                .foregroundColor(.gray)

                Text("Elite")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(accentOrange.opacity(0.8)))

                Text("12 sessions")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

            Button(action: {}) {
                HStack(spacing: 6) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 12))
                    Text("Start Program")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [accentOrange, accentOrange.opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .padding(.top, 4)
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

    // MARK: - Target Areas

    private var targetAreasCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Target Areas")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(areas, id: \.self) { area in
                        Button(action: {
                            selectedArea = selectedArea == area ? nil : area
                        }) {
                            Text(area)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(selectedArea == area ? .black : .white.opacity(0.8))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedArea == area
                                              ? accentTeal
                                              : Color.white.opacity(0.06))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedArea == area
                                                ? Color.clear
                                                : Color.white.opacity(0.08), lineWidth: 1)
                                )
                        }
                    }
                }
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

    // MARK: - All Programs

    private var allProgramsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("All Programs")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            programRow(
                title: "Achilles/Calf Strengthening",
                area: "Achilles/Calf",
                description: "Progressive isometric holds targeting lower leg stability and endurance",
                duration: "15 min",
                level: "Beginner",
                levelColor: accentGreen,
                sessions: "8 sessions",
                iconColor: accentPurple
            )

            programRow(
                title: "Knee Stabilization",
                area: "Knee",
                description: "Build stability around the knee joint with guided holds",
                duration: "20 min",
                level: "Intermediate",
                levelColor: accentTeal,
                sessions: "10 sessions",
                iconColor: accentTeal
            )

            programRow(
                title: "Shoulder Recovery",
                area: "Shoulder",
                description: "Gentle progressive loading for shoulder rehabilitation",
                duration: "15 min",
                level: "Beginner",
                levelColor: accentGreen,
                sessions: "6 sessions",
                iconColor: accentOrange
            )
        }
    }

    private func programRow(title: String, area: String, description: String, duration: String, level: String, levelColor: Color, sessions: String, iconColor: Color) -> some View {
        HStack(alignment: .top, spacing: 14) {
            // Icon
            Circle()
                .fill(iconColor.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "scope")
                        .font(.system(size: 18))
                        .foregroundColor(iconColor)
                )

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Spacer()
                    Text(area)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.white.opacity(0.06)))
                }

                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .lineSpacing(2)

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                        Text(duration)
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.gray)

                    Text(level)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(levelColor.opacity(0.6)))

                    Text(sessions)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)

                    Spacer()

                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 9))
                            Text("Start")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(accentTeal)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(accentTeal.opacity(0.15))
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}
