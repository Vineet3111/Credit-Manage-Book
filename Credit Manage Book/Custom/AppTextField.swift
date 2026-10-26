//
//  AppTextField.swift
//  Credit Manage Book
//

import SwiftUI

struct AppTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var lineLimit: ClosedRange<Int> = 1...1
    var fieldBackground = Color(.systemBackground)

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.medium))
            TextField(placeholder, text: $text, axis: .vertical)
                .lineLimit(lineLimit)
                .padding(14)
                .background(fieldBackground, in: RoundedRectangle(cornerRadius: 12))
        }
    }
}
