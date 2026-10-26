//
//  Decimal+Rounding.swift
//  Credit Manage Book
//

import Foundation

extension Decimal {
    /// Rounds to 2 decimal places (paise) using plain rounding. Use for every stored rupee amount.
    var roundedToPaise: Decimal {
        var value = self
        var result = Decimal()
        NSDecimalRound(&result, &value, 2, .plain)
        return result
    }
}
