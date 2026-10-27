//
//  AddCreditView.swift
//  Credit Manage Book
//

import SwiftUI
import SwiftData

struct AddCreditView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Customer.name) private var customers: [Customer]
    @Query(filter: #Predicate<Product> { $0.isActive }, sort: \Product.name) private var products: [Product]
    @StateObject private var viewModel: AddCreditViewModel

    init(customer: Customer? = nil) {
        _viewModel = StateObject(wrappedValue: AddCreditViewModel(customer: customer))
    }

    var body: some View {
        VStack(spacing: 0) {
            CustomNavBar(title: "Add Credit") { dismiss() }
            ScrollView {
                VStack(spacing: 16) {
                    SelectionField(
                        title: "Customer",
                        value: viewModel.selectedCustomer?.name ?? "",
                        placeholder: "Select customer"
                    ) {
                        viewModel.showCustomerSelection()
                    }
                    ForEach($viewModel.items) { $item in
                        itemCard($item)
                    }
                    grandTotalRow
                    AppButton(title: "Add Item", systemImage: "plus", style: .outlined, action: viewModel.addItem)
                    AppButton(title: "Continue to Summary", isDisabled: !viewModel.canContinue) {
                        viewModel.showSummary = true
                    }
                }
                .padding()
            }
        }
        .background(Color("BackgroundSc"))
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $viewModel.activeSheet) { sheetType in
            switch sheetType {
            case .customerSelection:
                customerSheet
            case .productSelection:
                productSheet
            case .addCustomer:
                NavigationStack {
                    AddCustomerView()
                }
            case .addProduct:
                NavigationStack {
                    AddProductView()
                }
            }
        }
        .navigationDestination(isPresented: $viewModel.showSummary) { SummaryView(viewModel: viewModel) }
        .overlay(alignment: .bottom) {
            if viewModel.showToast {
                ToastView(message: "Credit saved", isPresented: $viewModel.showToast)
            }
        }
        .animation(.easeInOut, value: viewModel.showToast)
    }

    // MARK: - Subviews

    private func itemCard(_ item: Binding<CreditItemDraft>) -> some View {
        let number = (viewModel.items.firstIndex { $0.id == item.wrappedValue.id } ?? 0) + 1
        let fieldBackground = Color(.systemGroupedBackground)
        let hasProduct = !item.wrappedValue.productName.isEmpty
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Item \(number)")
                    .font(.headline)
                Spacer()
                if viewModel.items.count > 1 {
                    Button { viewModel.removeItem(item.wrappedValue) } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                }
            }
            Divider()
            SelectionField(
                title: "PRODUCT NAME",
                value: item.wrappedValue.productName,
                placeholder: "Select product",
                fieldBackground: fieldBackground
            ) { viewModel.chooseProduct(for: item.wrappedValue) }
            HStack(alignment: .top, spacing: 10) {
                SelectionField(
                    title: "UNIT",
                    value: hasProduct ? item.wrappedValue.unit.title() : "",
                    placeholder: "Unit",
                    fieldBackground: fieldBackground
                )
                SelectionField(
                    title: "PRICE",
                    value: hasProduct ? item.wrappedValue.price.inrFormatted : "",
                    placeholder: "Price",
                    fieldBackground: fieldBackground
                )
                AppTextField(title: "QUANTITY", placeholder: "Qty", text: item.quantity, fieldBackground: fieldBackground)
                    .keyboardType(.decimalPad)
            }
            HStack {
                Text("TOTAL AMOUNT")
                    .font(.subheadline)
                Spacer()
                Text(item.wrappedValue.totalAmount.inrFormatted)
                    .font(.headline)
                    .foregroundStyle(.green)
            }
        }
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private var grandTotalRow: some View {
        HStack {
            Text("GRAND TOTAL")
                .font(.subheadline.weight(.semibold))
            Spacer()
            Text(viewModel.grandTotal.inrFormatted)
                .font(.title3.bold())
        }
        .padding(.horizontal, 4)
    }

    private var customerSheet: some View {
        VStack(spacing: 16) {
            SearchBar(text: $viewModel.searchText, placeholder: "Search customer")
            ScrollView {
                LazyVStack(spacing: 10) {
                    let results = viewModel.filteredCustomers(customers)
                    if results.isEmpty {
                        VStack(spacing: 12) {
                            Text("No customers found.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Button {
                                viewModel.addCustomerTapped()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add New Customer")
                                        .fontWeight(.medium)
                                }
                                .foregroundStyle(.indigo)
                            }
                        }
                        .padding(.top, 24)
                    }
                    ForEach(results) { customer in
                        customerRow(customer)
                    }
                }
            }
            
            // Add Customer button at bottom
            AppButton(
                title: "Add New Customer",
                systemImage: "plus.circle.fill",
                style: .outlined,
                action: viewModel.addCustomerTapped
            )
        }
        .padding()
        .padding(.top, 12)
        .background(Color(.systemGroupedBackground))
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func customerRow(_ customer: Customer) -> some View {
        Button {
            viewModel.select(customer)
        } label: {
            HStack(spacing: 12) {
                CustomImage(name: customer.name, size: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text(customer.name)
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                    Text(customer.address)
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                }
                Spacer()
                if customer == viewModel.selectedCustomer {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.indigo)
                }
            }
            .padding(12)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 14))
        }
    }

    private var productSheet: some View {
        VStack(spacing: 16) {
            SearchBar(text: $viewModel.productSearchText, placeholder: "Search product")
            ScrollView {
                LazyVStack(spacing: 10) {
                    let results = viewModel.filteredProducts(products)
                    if results.isEmpty {
                        VStack(spacing: 12) {
                            Text("No products found.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Button {
                                viewModel.addProductTapped()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add New Product")
                                        .fontWeight(.medium)
                                }
                                .foregroundStyle(.indigo)
                            }
                        }
                        .padding(.top, 24)
                    }
                    ForEach(results) { product in
                        productRow(product)
                    }
                }
            }
            
            // Add Product button at bottom
            AppButton(
                title: "Add New Product",
                systemImage: "plus.circle.fill",
                style: .outlined,
                action: viewModel.addProductTapped
            )
        }
        .padding()
        .padding(.top, 12)
        .background(Color(.systemGroupedBackground))
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func productRow(_ product: Product) -> some View {
        Button {
            viewModel.select(product)
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(product.name)
                    .font(.headline)
                    .foregroundStyle(Color.primary)
                Text("\(product.price.inrFormatted) / \(product.unit.title())")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 14))
        }
    }
}
