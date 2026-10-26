//
//  UnitPicker.swift
//  Credit Manage Book
//

import SwiftUI

/// Labeled menu for choosing a `ProductUnit`. The whole box is tappable.
struct UnitPicker: View {
    @Binding var unit: ProductUnit
    var title = "Unit"
    var fieldBackground = Color(.systemBackground)

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.medium))
            Menu {
                Picker(title, selection: $unit) {
                    ForEach(ProductUnit.allCases) { unit in
                        Text(unit.title()).tag(unit)
                    }
                }
            } label: {
                HStack {
                    Text(unit.title())
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.footnote)
                }
                .foregroundStyle(.black)
                .padding(14)
                .frame(maxWidth: .infinity)
                .background(fieldBackground, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

#Preview {
    UnitPicker(unit: .constant(.kg))
        .padding()
}
