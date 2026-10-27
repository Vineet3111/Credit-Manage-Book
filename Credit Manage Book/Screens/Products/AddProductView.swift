//
//  AddProductView.swift
//  Credit Manage Book
//

import SwiftUI
import SwiftData

struct AddProductView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Product.name) private var products: [Product]
    @StateObject private var viewModel = AddProductViewModel()

    var body: some View {
        VStack(spacing: 0) {
            CustomNavBar(title: viewModel.editingProduct == nil ? "Add Product" : "Edit Product")
            ScrollView {
                VStack(spacing: 16) {
                    fields
                    if let message = viewModel.errorMessage {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                    AppButton(
                        title: viewModel.editingProduct == nil ? "Save" : "Update",
                        isDisabled: !viewModel.canSave
                    ) {
                        viewModel.save(in: modelContext)
                    }
                    if viewModel.editingProduct != nil {
                        AppButton(title: "Cancel Edit", style: .outlined, action: viewModel.cancelEditing)
                    }
                    AppButton(title: "View All Products", systemImage: "list.bullet", style: .outlined) {
                        viewModel.showProductsSheet = true
                    }
                }
                .padding()
            }
        }
        .background(Color("BackgroundSc"))
        .sheet(isPresented: $viewModel.showProductsSheet) {
            productsSheet
        }
        .overlay(alignment: .bottom) {
            if viewModel.showToast {
                ToastView(message: viewModel.toastMessage, isPresented: $viewModel.showToast)
            }
        }
        .animation(.easeInOut, value: viewModel.showToast)
    }

    // MARK: - Subviews

    private var fields: some View {
        VStack(spacing: 16) {
            AppTextField(title: "Product Name", placeholder: "Enter product name", text: $viewModel.name)
            AppTextField(title: "Price (₹)", placeholder: "Enter price per unit", text: $viewModel.price)
                .keyboardType(.decimalPad)
            UnitPicker(unit: $viewModel.unit)
        }
    }

    private var productsSheet: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                if products.isEmpty {
                    Text("No products yet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.top, 24)
                }
                ForEach(products) { product in
                    productRow(product)
                }
            }
            .padding()
            .padding(.top, 12)
        }
        .background(Color(.systemGroupedBackground))
        .confirmationDialog(
            "Delete product?",
            isPresented: $viewModel.showDeleteConfirmation,
            titleVisibility: .visible,
            presenting: viewModel.productToDelete
        ) { _ in
            Button("Delete", role: .destructive) { viewModel.confirmDelete(in: modelContext) }
        } message: { product in
            Text("\(product.name) will be removed. Credits already saved are not changed.")
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func productRow(_ product: Product) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(product.name)
                    .font(.headline)
                Text("\(product.price.inrFormatted) / \(product.unit.title())")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button { viewModel.startEditing(product) } label: {
                Image(systemName: "pencil")
                    .foregroundStyle(.indigo)
            }
            .padding(.trailing, 8)
            Button { viewModel.deleteTapped(product) } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
        }
        .padding(12)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 14))
    }
}
