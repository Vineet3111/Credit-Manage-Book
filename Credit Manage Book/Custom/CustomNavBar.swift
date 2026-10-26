//
//  CustomNavBar.swift
//  Credit Manage Book
//

import SwiftUI

/// Top bar used instead of the system navigation bar on every screen. Omit `onBack` on tab root screens.
struct CustomNavBar: View {
    let title: String
    var onBack: (() -> Void)?

    var body: some View {
        ZStack {
            Text(title)
                .font(.headline)
            if let onBack {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                    }
                    Spacer()
                }
            }
        }
        .foregroundStyle(.white)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.indigo.ignoresSafeArea(edges: .top))
    }
}

#Preview {
    CustomNavBar(title: "Add Customer") {}
}
