//
//  AddCreditViewModel.swift
//  Credit Manage Book
//

import Foundation
import Combine

final class AddCreditViewModel: ObservableObject {
    @Published var selectedCustomer: Customer?
    @Published var showCustomerSheet = false
    @Published var searchText = ""
    @Published var items = [CreditItemDraft()]
    @Published var showProductSheet = false
    @Published var productSearchText = ""
    private var editingItemID: UUID?

    init(customer: Customer?) {
        selectedCustomer = customer
    }

    var grandTotal: Decimal {
        items.reduce(0) { $0 + $1.totalAmount }.roundedToPaise
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
}
