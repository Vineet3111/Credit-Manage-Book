//
//  DetailsViewModel.swift
//  Credit Manage Book
//

import Foundation
import Combine
import SwiftData

final class DetailsViewModel: ObservableObject {
    /// The customer whose credits are shown in the sheet.
    @Published var selectedCustomer: Customer?
    @Published var paymentAmount = ""
    @Published var errorMessage: String?
    @Published var showToast = false

    var paymentValue: Decimal {
        (Decimal(string: paymentAmount.trimmingCharacters(in: .whitespaces), locale: .current) ?? 0).roundedToPaise
    }

    func select(_ customer: Customer) {
        paymentAmount = ""
        errorMessage = nil
        selectedCustomer = customer
    }

    /// Newest credit first.
    func sortedCredits(for customer: Customer) -> [Credit] {
        customer.credits.sorted { $0.date > $1.date }
    }

    /// A payment must be above 0 and cannot be more than what the customer owes.
    func canSavePayment(for customer: Customer) -> Bool {
        paymentValue > 0 && paymentValue <= customer.outstanding
    }

    var isPaymentTooHigh: Bool {
        guard let customer = selectedCustomer else { return false }
        return paymentValue > customer.outstanding
    }

    /// Spreads the payment over the oldest unpaid credits so every credit's balance stays correct.
    func savePayment(for customer: Customer, in context: ModelContext) {
        guard canSavePayment(for: customer) else { return }
        var left = paymentValue
        for credit in customer.credits.sorted(by: { $0.date < $1.date }) {
            guard left > 0 else { break }
            let part = min(left, credit.outstanding)
            guard part > 0 else { continue }
            context.insert(Payment(customer: customer, amount: part, credit: credit))
            left -= part
        }
        do {
            try context.save()
            errorMessage = nil
            paymentAmount = ""
            showToast = true
        } catch {
            errorMessage = "Could not save payment. Please try again."
        }
    }
}
