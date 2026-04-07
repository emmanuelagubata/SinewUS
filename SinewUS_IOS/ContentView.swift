// ============================================================
// ContentView.swift — Root view that switches between
// Connect (Page 1) and Live Dashboard (Page 2)
// ============================================================

import SwiftUI

struct ContentView: View {
    @StateObject private var bleManager = BLEManager()
    @StateObject private var sessionManager = SessionManager()
    @State private var showLiveSession = false

    var body: some View {
        ZStack {
            if showLiveSession {
                LiveSessionView(
                    bleManager: bleManager,
                    sessionManager: sessionManager,
                    onDisconnect: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showLiveSession = false
                        }
                    }
                )
                .transition(.move(edge: .trailing))
            } else {
                ConnectView(
                    bleManager: bleManager,
                    onConnected: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showLiveSession = true
                        }
                    }
                )
                .transition(.move(edge: .leading))
            }
        }
    }
}
