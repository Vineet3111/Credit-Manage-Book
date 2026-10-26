//
//  Customer.swift
//  Credit Manage Book
//

import Foundation
import SwiftData

@Model
final class Customer {
    @Attribute(.unique) var id: UUID
    var name: String
    var phone: String
    var address: String
    var notes: String?
    var createdAt: Date
    var isActive: Bool

    @Relationship(deleteRule: .cascade, inverse: \Credit.customer)
    var credits: [Credit] = []

    @Relationship(deleteRule: .cascade, inverse: \Payment.customer)
    var payments: [Payment] = []

    init(name: String, phone: String, address: String, notes: String? = nil, createdAt: Date = .now, isActive: Bool = true) {
        self.id = UUID()
        self.name = name
        self.phone = phone
        self.address = address
        self.notes = notes
        self.createdAt = createdAt
        self.isActive = isActive
    }

    var totalCredit: Decimal { credits.reduce(0) { $0 + $1.total }.roundedToPaise }
    var totalPaid: Decimal { payments.reduce(0) { $0 + $1.amount }.roundedToPaise }
    var outstanding: Decimal { (totalCredit - totalPaid).roundedToPaise }
    var hasRecords: Bool { !credits.isEmpty || !payments.isEmpty }
}
