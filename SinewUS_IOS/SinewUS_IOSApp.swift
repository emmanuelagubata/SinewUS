// ============================================================
// SinewUS_IOSApp.swift — App entry point
// ============================================================

import SwiftUI

@main
struct SinewUS_IOSApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
        }
    }
}
