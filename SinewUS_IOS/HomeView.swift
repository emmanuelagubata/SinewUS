// ============================================================
// HomeView.swift — Placeholder for future Home tab
// ============================================================

import SwiftUI

struct HomeView: View {
    private let bg = Color(red: 0.06, green: 0.08, blue: 0.14)

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()
            VStack(spacing: 12) {
                Image("TabIcon-Home")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
                    .foregroundColor(.gray.opacity(0.4))
                Text("Home")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text("Coming soon")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
    }
}
