//
//  ToastView.swift
//  Credit Manage Book
//

import SwiftUI

/// Banner with a title and message, green for success and red for error.
/// Show it with `if showToast { ToastView(...) }`; it hides itself after 2 seconds.
struct ToastView: View {
    let message: String
    var style: ToastStyle = .success
    @Binding var isPresented: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: style.icon)
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text(style.title)
                    .font(.subheadline.weight(.bold))
                Text(message)
                    .font(.footnote)
            }
            Spacer(minLength: 0)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(style.color, in: RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .task {
            try? await Task.sleep(for: .seconds(2))
            isPresented = false
        }
    }
}
