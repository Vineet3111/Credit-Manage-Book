//
//  SearchBar.swift
//  Credit Manage Book
//

import SwiftUI

/// Search field with a magnifier icon and a clear button.
struct SearchBar: View {
    @Binding var text: String
    var placeholder = "Search"

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(placeholder, text: $text)
                .autocorrectionDisabled()
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    SearchBar(text: .constant(""), placeholder: "Search customer")
        .padding()
}
