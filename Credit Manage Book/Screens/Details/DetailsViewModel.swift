//
//  DetailsViewModel.swift
//  Credit Manage Book
//

import Foundation
import Combine
import SwiftData

enum CreditDateFilter: String, CaseIterable, Identifiable {
    case all = "All Time"
    case thisMonth = "This Month"
    case lastMonth = "Last Month"
    case customRange = "Custom Range"
    
    var id: String { rawValue }
}

final class DetailsViewModel: ObservableObject {
    /// The customer whose credits are shown in the sheet.
    @Published var selectedCustomer: Customer?
    @Published var paymentAmount = ""
    @Published var errorMessage: String?
    @Published var showToast = false
    @Published var toastMessage = "Payment saved"
    @Published var selectedFilter: CreditDateFilter = .all
    @Published var customStartDate: Date = Date()
    @Published var customEndDate: Date = Date()
    @Published var showDatePicker = false

    var paymentValue: Decimal {
        (Decimal(string: paymentAmount.trimmingCharacters(in: .whitespaces), locale: .current) ?? 0).roundedToPaise
    }

    func select(_ customer: Customer) {
        paymentAmount = ""
        errorMessage = nil
        selectedCustomer = customer
        selectedFilter = .all // Reset filter when selecting new customer
    }

    /// Newest credit first, filtered by selected date range.
    func sortedCredits(for customer: Customer) -> [Credit] {
        let filtered = filteredCredits(customer.credits)
        return filtered.sorted { $0.date > $1.date }
    }
    
    private func filteredCredits(_ credits: [Credit]) -> [Credit] {
        switch selectedFilter {
        case .all:
            return credits
        case .thisMonth:
            return credits.filter {
                isInCurrentMonth($0.date)
            }
        case .lastMonth:
            return credits.filter {
                isInLastMonth($0.date)
            }
        case .customRange:
            return credits.filter {
                isInCustomRange($0.date)
            }
        }
    }
    
    private func isInCurrentMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date, equalTo: Date(), toGranularity: .month)
    }
    
    private func isInLastMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: Date()) else {
            return false
        }
        return calendar.isDate(date, equalTo: lastMonth, toGranularity: .month)
    }
    
    private func isInCustomRange(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: customStartDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: customEndDate)) ?? customEndDate
        return date >= startOfDay && date < endOfDay
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
            toastMessage = "Payment saved"
            showToast = true
        } catch {
            errorMessage = "Could not save payment. Please try again."
        }
    }
}
