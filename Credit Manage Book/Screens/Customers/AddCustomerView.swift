//
//  AddCustomerView.swift
//  Credit Manage Book
//

import SwiftUI
import SwiftData

struct AddCustomerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Customer.name) private var customers: [Customer]
    @StateObject private var viewModel = AddCustomerViewModel()

    var body: some View {
        VStack(spacing: 0) {
            CustomNavBar(title: viewModel.editingCustomer == nil ? "Add Customer" : "Edit Customer") { dismiss() }
            ScrollView {
                VStack(spacing: 16) {
                    fields
                    if let message = viewModel.errorMessage {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                    AppButton(
                        title: viewModel.editingCustomer == nil ? "Save" : "Update",
                        isDisabled: !viewModel.canSave
                    ) {
                        viewModel.save(in: modelContext)
                    }
                    if viewModel.editingCustomer != nil {
                        AppButton(title: "Cancel Edit", style: .outlined, action: viewModel.cancelEditing)
                    }
                    AppButton(title: "View All Customers", systemImage: "list.bullet", style: .outlined) {
                        viewModel.showCustomersSheet = true
                    }
                }
                .padding()
            }
        }
        .background(Color("BackgroundSc"))
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $viewModel.showCustomersSheet) {
            customersSheet
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
            VStack(alignment: .leading, spacing: 4) {
                AppTextField(title: "Name", placeholder: "Enter customer name", text: $viewModel.name)
                if let message = viewModel.nameValidationMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            AppTextField(title: "Phone", placeholder: "Enter 10 digit phone number", text: $viewModel.phone)
                .keyboardType(.phonePad)
            AppTextField(title: "Address", placeholder: "Enter address", text: $viewModel.address)
            AppTextField(title: "Notes (optional)", placeholder: "Add a note", text: $viewModel.notes, lineLimit: 2...4)
        }
    }

    private var customersSheet: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                if customers.isEmpty {
                    Text("No customers yet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.top, 24)
                }
                ForEach(customers) { customer in
                    customerRow(customer)
                }
            }
            .padding()
            .padding(.top, 12)
        }
        .background(Color(.systemGroupedBackground))
        .confirmationDialog(
            "Delete customer?",
            isPresented: $viewModel.showDeleteConfirmation,
            titleVisibility: .visible,
            presenting: viewModel.customerToDelete
        ) { _ in
            Button("Delete", role: .destructive) { viewModel.confirmDelete(in: modelContext) }
        } message: { customer in
            Text("\(customer.name) and all their credits and payments will be deleted.")
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func customerRow(_ customer: Customer) -> some View {
        HStack(spacing: 12) {
            CustomImage(name: customer.name)
            VStack(alignment: .leading, spacing: 2) {
                Text(customer.name)
                    .font(.headline)
                Text(customer.phone)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(customer.address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button { viewModel.startEditing(customer) } label: {
                Image(systemName: "pencil")
                    .foregroundStyle(.indigo)
            }
            .padding(.trailing, 8)
            Button { viewModel.deleteTapped(customer) } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
        }
        .padding(12)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 14))
    }
}
