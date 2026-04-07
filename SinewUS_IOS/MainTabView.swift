// ============================================================
// MainTabView.swift — Bottom tab navigation with custom icons
// ============================================================

import SwiftUI

struct MainTabView: View {
    @StateObject private var bleManager = BLEManager()
    @StateObject private var sessionManager = SessionManager()
    @State private var selectedTab = 0

    // Theme
    private let accentTeal = Color(red: 0.15, green: 0.85, blue: 0.75)
    private let bg = Color(red: 0.06, green: 0.08, blue: 0.14)

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            TabView(selection: $selectedTab) {
                ConnectTab(bleManager: bleManager, sessionManager: sessionManager, switchToHome: {
                    withAnimation { selectedTab = 1 }
                })
                .tag(0)

                LiveSessionView(
                    bleManager: bleManager,
                    sessionManager: sessionManager,
                    onDisconnect: {
                        withAnimation { selectedTab = 0 }
                    }
                )
                .tag(1)

                AnalyticsView()
                    .tag(2)

                TrainingView()
                    .tag(3)

                ProfileView()
                    .tag(4)
            }
            // Hide the default tab bar
            .tabViewStyle(.automatic)
            .onAppear {
                UITabBar.appearance().isHidden = true
            }

            // Custom tab bar
            customTabBar
        }
        .ignoresSafeArea(.keyboard)
    }

    // MARK: - Custom Tab Bar

    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabButton(icon: "TabIcon-Connect", label: "Connect", index: 0)
            tabButton(icon: "TabIcon-Home", label: "Home", index: 1)
            tabButton(icon: "TabIcon-Analytics", label: "Analytics", index: 2)
            tabButton(icon: "TabIcon-Book", label: "Training", index: 3)
            tabButton(icon: "TabIcon-Profile", label: "Profile", index: 4)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 12)
    }

    private func tabButton(icon: String, label: String, index: Int) -> some View {
        Button(action: { withAnimation(.easeInOut(duration: 0.2)) { selectedTab = index } }) {
            VStack(spacing: 4) {
                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)

                Text(label)
                    .font(.system(size: 9, weight: .medium))
            }
            .foregroundColor(selectedTab == index ? accentTeal : .gray.opacity(0.6))
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Connect Tab wrapper (handles auto-navigation on BLE connect)

private struct ConnectTab: View {
    @ObservedObject var bleManager: BLEManager
    @ObservedObject var sessionManager: SessionManager
    var switchToHome: () -> Void

    var body: some View {
        ConnectView(
            bleManager: bleManager,
            onConnected: { switchToHome() }
        )
    }
}
