//
//  AddProductViewModel.swift
//  Credit Manage Book
//

import Foundation
import Combine
import SwiftData

final class AddProductViewModel: ObservableObject {
    @Published var name = ""
    @Published var price = ""
    @Published var unit: ProductUnit = .kg
    @Published var errorMessage: String?
    @Published var showToast = false

    private var parsedPrice: Decimal? {
        Decimal(string: price.trimmingCharacters(in: .whitespaces), locale: .current)
    }

    var canSave: Bool {
        let hasName = !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return hasName && (parsedPrice ?? 0) > 0
    }

    /// Saves the product, clears the form and shows the toast.
    func save(in context: ModelContext) {
        guard let parsedPrice else { return }
        let product = Product(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            price: parsedPrice,
            unit: unit
        )
        context.insert(product)
        do {
            try context.save()
            errorMessage = nil
            name = ""
            price = ""
            unit = .kg
            showToast = true
        } catch {
            errorMessage = "Could not save product. Please try again."
        }
    }
}
