//
//  Payment.swift
//  Credit Manage Book
//

import Foundation
import SwiftData

@Model
final class Payment {
    @Attribute(.unique) var id: UUID
    var amount: Decimal
    var date: Date
    var note: String?

    var customer: Customer?
    /// Optional: the credit this payment is allocated to.
    var credit: Credit?

    init(customer: Customer, amount: Decimal, date: Date = .now, note: String? = nil, credit: Credit? = nil) {
        self.id = UUID()
        self.customer = customer
        self.amount = amount.roundedToPaise
        self.date = date
        self.note = note
        self.credit = credit
    }
}
