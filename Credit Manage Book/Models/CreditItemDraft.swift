//
//  CreditItemDraft.swift
//  Credit Manage Book
//

import Foundation

/// An item being typed into the Add Credit form. It is not saved; it becomes a `CreditItem` later.
struct CreditItemDraft: Identifiable {
    let id = UUID()
    var productName = ""
    var unit: ProductUnit = .kg
    var price: Decimal = 0
    var quantity = ""

    var totalAmount: Decimal {
        let quantityValue = Decimal(string: quantity, locale: .current) ?? 0
        return (price * quantityValue).roundedToPaise
    }

    var isValid: Bool {
        !productName.isEmpty && totalAmount > 0
    }

    /// Fills name, unit and price from the chosen product.
    mutating func apply(_ product: Product) {
        productName = product.name
        unit = product.unit
        price = product.price
    }
}
