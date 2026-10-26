//
//  Decimal+Currency.swift
//  Credit Manage Book
//

import Foundation

extension Decimal {
    /// Rupee string with Indian digit grouping, e.g. ₹1,23,456.50.
    var inrFormatted: String {
        formatted(.currency(code: "INR").locale(Locale(identifier: "en_IN")))
    }
}
