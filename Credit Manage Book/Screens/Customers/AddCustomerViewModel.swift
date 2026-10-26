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

    var canSave: Bool {
        !trimmed(name).isEmpty && phone.filter(\.isNumber).count == 10 && !trimmed(address).isEmpty
    }

    func save(in context: ModelContext) {
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
            emptyTextField()
        } catch {
            errorMessage = "Could not save customer. Please try again."
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
