//
//  DashboardViewModel.swift
//  Credit Manage Book
//

import Foundation
import Combine
import SwiftData

final class DashboardViewModel: ObservableObject {
    @Published var path: [DashboardRoute] = []
    @Published var customerToDelete: Customer?
    @Published var showDeleteConfirmation = false

    func greeting(at date: Date = .now, calendar: Calendar = .current) -> String {
        switch calendar.component(.hour, from: date) {
        case ..<12: "Good Morning"
        case ..<17: "Good Afternoon"
        default: "Good Evening"
        }
    }

    func totalOutstanding(for customers: [Customer]) -> Decimal {
        customers.reduce(0) { $0 + $1.outstanding }.roundedToPaise
    }

    func addCustomerTapped() {
        path.append(.addCustomer)
    }
    
    func addCreditTapped(for customer: Customer? = nil) {
        path.append(.addCredit(customer))
    }

    func deleteTapped(_ customer: Customer) {
        customerToDelete = customer
        showDeleteConfirmation = true
    }

    func confirmDelete(in context: ModelContext) {
        if let customer = customerToDelete {
            context.delete(customer)
        }
        customerToDelete = nil
    }
}
