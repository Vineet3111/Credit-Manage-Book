//
//  CustomImage.swift
//  Credit Manage Book
//

import SwiftUI

/// Round avatar showing the first letter of a name.
struct CustomImage: View {
    let name: String
    var size: CGFloat = 46

    var body: some View {
        Text(name.prefix(1).uppercased())
            .font(.title3.weight(.semibold))
            .foregroundStyle(.indigo)
            .frame(width: size, height: size)
            .background(Color.indigo.opacity(0.12), in: Circle())
    }
}
