//
//  AppButton.swift
//  Credit Manage Book
//

import SwiftUI

/// Full-width blue button. `.filled` for save/confirm, `.outlined` for secondary actions.
struct AppButton: View {
    enum Style { case filled, outlined }

    let title: String
    var systemImage: String?
    var style: Style = .filled
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if let systemImage {
                    Label(title, systemImage: systemImage)
                } else {
                    Text(title)
                }
            }
            .font(.headline)
            .foregroundStyle(style == .filled ? Color.white : Color.indigo)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(style == .filled ? Color.indigo : Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                if style == .outlined {
                    RoundedRectangle(cornerRadius: 12).stroke(Color.indigo.opacity(0.5))
                }
            }
            .opacity(isDisabled ? 0.4 : 1)
        }
        .disabled(isDisabled)
    }
}

#Preview {
    VStack {
        AppButton(title: "Add Item", systemImage: "plus", style: .outlined) {}
        AppButton(title: "Save") {}
    }
    .padding()
}
