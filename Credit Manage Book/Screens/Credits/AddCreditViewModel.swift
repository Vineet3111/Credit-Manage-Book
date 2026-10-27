//
//  AddCreditViewModel.swift
//  Credit Manage Book
//

import Foundation
import Combine
import SwiftData

final class AddCreditViewModel: ObservableObject {
    @Published var selectedCustomer: Customer?
    @Published var showCustomerSheet = false
    @Published var searchText = ""
    @Published var items = [CreditItemDraft()]
    @Published var showProductSheet = false
    @Published var productSearchText = ""
    @Published var showSummary = false
    @Published var showToast = false
    @Published var errorMessage: String?
    @Published var paidAmount = ""
    @Published var showAddCustomerSheet = false
    @Published var showAddProductSheet = false
    private var editingItemID: UUID?

    init(customer: Customer?) {
        selectedCustomer = customer
    }

    var grandTotal: Decimal {
        items.reduce(0) { $0 + $1.totalAmount }.roundedToPaise
    }

    var paidValue: Decimal {
        (Decimal(string: paidAmount.trimmingCharacters(in: .whitespaces), locale: .current) ?? 0).roundedToPaise
    }

    var remainingAmount: Decimal {
        (grandTotal - paidValue).roundedToPaise
    }

    /// The paid amount may be empty (nothing paid) but cannot be more than the grand total.
    var isPaidAmountValid: Bool {
        paidValue <= grandTotal
    }

    var canContinue: Bool {
        selectedCustomer != nil && items.allSatisfy(\.isValid)
    }

    func addItem() {
        items.append(CreditItemDraft())
    }

    func filteredCustomers(_ customers: [Customer]) -> [Customer] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return customers }
        return customers.filter {
            $0.name.localizedCaseInsensitiveContains(query) || $0.address.localizedCaseInsensitiveContains(query)
        }
    }

    func select(_ customer: Customer) {
        selectedCustomer = customer
        showCustomerSheet = false
        searchText = ""
    }
    
    func addCustomerTapped() {
        showCustomerSheet = false
        showAddCustomerSheet = true
    }

    func removeItem(_ item: CreditItemDraft) {
        guard items.count > 1 else { return }
        items.removeAll { $0.id == item.id }
    }

    func chooseProduct(for item: CreditItemDraft) {
        editingItemID = item.id
        showProductSheet = true
    }

    func filteredProducts(_ products: [Product]) -> [Product] {
        let query = productSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return products }
        return products.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    func select(_ product: Product) {
        if let index = items.firstIndex(where: { $0.id == editingItemID }) {
            items[index].apply(product)
        }
        showProductSheet = false
        productSearchText = ""
    }
    
    func addProductTapped() {
        showProductSheet = false
        showAddProductSheet = true
    }

    /// Saves the credit with its items, clears the form, goes back to it and shows the toast.
    func saveCredit(in context: ModelContext) {
        guard let customer = selectedCustomer else { return }
        let credit = Credit(customer: customer)
        credit.items = items.map {
            CreditItem(productName: $0.productName, quantity: $0.quantityValue, unit: $0.unit, pricePerUnit: $0.price)
        }
        context.insert(credit)
        if paidValue > 0 {
            context.insert(Payment(customer: customer, amount: paidValue, credit: credit))
        }
        do {
            try context.save()
            errorMessage = nil
            selectedCustomer = nil
            items = [CreditItemDraft()]
            paidAmount = ""
            showSummary = false
            showToast = true
        } catch {
            errorMessage = "Could not save credit. Please try again."
        }
    }
}
