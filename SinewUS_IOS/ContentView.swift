// ============================================================
// ContentView.swift — Root view that switches between
// Connect and Live Session screens
// ============================================================

import SwiftUI

struct ContentView: View {
    @StateObject private var bleManager = BLEManager()
    @StateObject private var sessionManager = SessionManager()
    @State private var showLiveSession = false

    var body: some View {
        if showLiveSession {
            LiveSessionView(
                bleManager: bleManager,
                sessionManager: sessionManager,
                onDisconnect: {
                    showLiveSession = false
                }
            )
        } else {
            ConnectView(
                bleManager: bleManager,
                onConnected: {
                    showLiveSession = true
                }
            )
        }
    }
}
