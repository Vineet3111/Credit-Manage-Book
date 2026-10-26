//
//  Credit.swift
//  Credit Manage Book
//

import Foundation
import SwiftData

@Model
final class Credit {
    @Attribute(.unique) var id: UUID
    var date: Date
    var note: String?

    var customer: Customer?

    @Relationship(deleteRule: .cascade, inverse: \CreditItem.credit)
    var items: [CreditItem] = []

    @Relationship(deleteRule: .nullify, inverse: \Payment.credit)
    var payments: [Payment] = []

    init(customer: Customer, date: Date = .now, note: String? = nil) {
        self.id = UUID()
        self.customer = customer
        self.date = date
        self.note = note
    }

    var total: Decimal { items.reduce(0) { $0 + $1.totalPrice }.roundedToPaise }
    var paid: Decimal { payments.reduce(0) { $0 + $1.amount }.roundedToPaise }
    var outstanding: Decimal { (total - paid).roundedToPaise }
}
