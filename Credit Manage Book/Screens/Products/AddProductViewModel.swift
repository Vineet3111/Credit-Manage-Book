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
    @Published var toastMessage = ""
    @Published var showProductsSheet = false
    @Published var showDeleteConfirmation = false
    @Published var productToDelete: Product?
    /// The product being edited in the form; nil when adding a new one.
    @Published var editingProduct: Product?

    private var parsedPrice: Decimal? {
        Decimal(string: price.trimmingCharacters(in: .whitespaces), locale: .current)
    }

    var canSave: Bool {
        let hasName = !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return hasName && (parsedPrice ?? 0) > 0
    }

    /// Saves a new product or updates the one being edited, clears the form and shows the toast.
    func save(in context: ModelContext) {
        guard let parsedPrice else { return }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let isEditing = editingProduct != nil
        if let product = editingProduct {
            product.name = trimmedName
            product.price = parsedPrice.roundedToPaise
            product.unit = unit
        } else {
            context.insert(Product(name: trimmedName, price: parsedPrice, unit: unit))
        }
        do {
            try context.save()
            clearForm()
            toastMessage = isEditing ? "Product updated" : "Product saved"
            showToast = true
        } catch {
            errorMessage = "Could not save product. Please try again."
        }
    }

    /// Fills the form with the product and closes the products sheet.
    func startEditing(_ product: Product) {
        editingProduct = product
        name = product.name
        price = product.price.formatted(.number.precision(.fractionLength(0...2)).grouping(.never))
        unit = product.unit
        errorMessage = nil
        showProductsSheet = false
    }

    func cancelEditing() {
        clearForm()
    }

    func deleteTapped(_ product: Product) {
        productToDelete = product
        showDeleteConfirmation = true
    }

    /// Credit items keep their own copy of name, unit and price, so old credits are not affected.
    func confirmDelete(in context: ModelContext) {
        if let product = productToDelete {
            if product === editingProduct {
                clearForm()
            }
            context.delete(product)
        }
        productToDelete = nil
    }

    private func clearForm() {
        editingProduct = nil
        errorMessage = nil
        name = ""
        price = ""
        unit = .kg
    }
}
