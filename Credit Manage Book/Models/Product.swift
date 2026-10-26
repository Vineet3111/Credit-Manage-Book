//
//  Product.swift
//  Credit Manage Book
//

import Foundation
import SwiftData

@Model
final class Product {
    var name: String
    var price: Decimal
    var unit: ProductUnit
    var createdAt: Date
    var isActive: Bool

    init(name: String, price: Decimal, unit: ProductUnit, createdAt: Date = .now, isActive: Bool = true) {
        self.name = name
        self.price = price.roundedToPaise
        self.unit = unit
        self.createdAt = createdAt
        self.isActive = isActive
    }
}
