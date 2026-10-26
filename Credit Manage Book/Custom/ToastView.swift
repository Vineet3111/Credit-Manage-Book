//
//  ToastView.swift
//  Credit Manage Book
//

import SwiftUI

/// Small message pill. Show it with `if showToast { ToastView(...) }`; it hides itself after 2 seconds.
struct ToastView: View {
    let message: String
    @Binding var isPresented: Bool

    var body: some View {
        Text(message)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.85), in: Capsule())
            .padding(.bottom, 40)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .task {
                try? await Task.sleep(for: .seconds(2))
                isPresented = false
            }
    }
}
