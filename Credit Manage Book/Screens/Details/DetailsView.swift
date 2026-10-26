//
//  DetailsView.swift
//  Credit Manage Book
//

import SwiftUI

/// Placeholder until the customer details screen is built.
struct DetailsView: View {
    var body: some View {
        VStack(spacing: 0) {
            CustomNavBar(title: "Details")
            Text("Customer details")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    DetailsView()
}
