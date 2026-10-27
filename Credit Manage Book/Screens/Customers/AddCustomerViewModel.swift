//
//  AddCustomerViewModel.swift
//  Credit Manage Book
//

import Foundation
import Combine
import SwiftData

final class AddCustomerViewModel: ObservableObject {
    @Published var name = ""
    @Published var phone = ""
    @Published var address = ""
    @Published var notes = ""
    @Published var errorMessage: String?
    @Published var showToast = false
    @Published var toastMessage = ""
    @Published var showCustomersSheet = false
    @Published var editingCustomer: Customer?
    @Published var showDeleteConfirmation = false
    @Published var customerToDelete: Customer?

    var canSave: Bool {
        let trimmedName = trimmed(name)
        let nameLength = trimmedName.count
        return nameLength >= 2 && nameLength <= 30 && phone.filter(\.isNumber).count == 10 && !trimmed(address).isEmpty
    }
    
    var nameValidationMessage: String? {
        let trimmedName = trimmed(name)
        let nameLength = trimmedName.count
        
        if trimmedName.isEmpty {
            return nil // Don't show error when field is empty
        } else if nameLength < 3 {
            return "Name must be at least 2 characters"
        } else if nameLength > 30 {
            return "Name must be 30 characters or less"
        }
        return nil
    }

    func save(in context: ModelContext) {
        if let editingCustomer = editingCustomer {
            // Update existing customer
            editingCustomer.name = trimmed(name)
            editingCustomer.phone = trimmed(phone)
            editingCustomer.address = trimmed(address)
            let notes = trimmed(notes)
            editingCustomer.notes = notes.isEmpty ? nil : notes
            
            do {
                try context.save()
                toastMessage = "Customer updated"
                emptyTextField()
                self.editingCustomer = nil
            } catch {
                errorMessage = "Could not update customer. Please try again."
            }
        } else {
            // Create new customer
            let notes = trimmed(notes)
            let customer = Customer(
                name: trimmed(name),
                phone: trimmed(phone),
                address: trimmed(address),
                notes: notes.isEmpty ? nil : notes
            )
            context.insert(customer)
            do {
                try context.save()
                toastMessage = "Customer saved"
                emptyTextField()
            } catch {
                errorMessage = "Could not save customer. Please try again."
            }
        }
    }

    func startEditing(_ customer: Customer) {
        editingCustomer = customer
        name = customer.name
        phone = customer.phone
        address = customer.address
        notes = customer.notes ?? ""
        showCustomersSheet = false
    }

    func cancelEditing() {
        editingCustomer = nil
        emptyTextField()
    }

    func deleteTapped(_ customer: Customer) {
        customerToDelete = customer
        showDeleteConfirmation = true
    }

    func confirmDelete(in context: ModelContext) {
        guard let customer = customerToDelete else { return }
        context.delete(customer)
        do {
            try context.save()
            customerToDelete = nil
        } catch {
            errorMessage = "Could not delete customer."
        }
    }

    private func emptyTextField() {
        errorMessage = nil
        name = ""
        phone = ""
        address = ""
        self.notes = ""
        showToast = true
    }
    
    private func trimmed(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
