//
//  SelectionField.swift
//  Credit Manage Book
//

import SwiftUI

/// Labeled field that cannot be typed into. With an `action` it acts as a picker button
/// (e.g. opens a sheet); without one it only displays the value.
struct SelectionField: View {
    let title: String
    let value: String
    let placeholder: String
    var fieldBackground = Color(.systemBackground)
    var action: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.medium))
            if let action {
                Button(action: action) { field }
            } else {
                field
            }
        }
    }

    private var field: some View {
        HStack {
            Text(value.isEmpty ? placeholder : value)
                .foregroundStyle(value.isEmpty ? Color.secondary : Color.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 0)
            if action != nil {
                Image(systemName: "chevron.down")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(fieldBackground, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    VStack {
        SelectionField(title: "Customer", value: "", placeholder: "Select customer") {}
        SelectionField(title: "UNIT", value: "Kg", placeholder: "Unit")
    }
    .padding()
}
