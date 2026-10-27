//
//  CreditItem.swift
//  Credit Manage Book
//

import Foundation
import SwiftData

@Model
final class CreditItem {
    var productName: String
    var quantity: Decimal
    var unit: ProductUnit
    var pricePerUnit: Decimal

    var credit: Credit?

    init(productName: String, quantity: Decimal, unit: ProductUnit, pricePerUnit: Decimal) {
        self.productName = productName
        self.quantity = quantity
        self.unit = unit
        self.pricePerUnit = pricePerUnit
    }

    /// Copies the product's name, unit and price so later product edits never change this item.
    init(product: Product, quantity: Decimal) {
        self.productName = product.name
        self.quantity = quantity
        self.unit = product.unit
        self.pricePerUnit = product.price
    }

    var totalPrice: Decimal { (quantity * pricePerUnit).roundedToPaise }
}
