//
//  AddCustomerView.swift
//  Credit Manage Book
//

import SwiftUI
import SwiftData

struct AddCustomerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = AddCustomerViewModel()

    var body: some View {
        VStack(spacing: 0) {
            CustomNavBar(title: "Add Customer") { dismiss() }
            ScrollView {
                VStack(spacing: 16) {
                    fields
                    if let message = viewModel.errorMessage {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                    AppButton(title: "Save", isDisabled: !viewModel.canSave) { viewModel.save(in: modelContext) }
                }
                .padding()
            }
        }
        .background(Color("BackgroundSc"))
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .bottom) {
            if viewModel.showToast {
                ToastView(message: "Customer saved", isPresented: $viewModel.showToast)
            }
        }
        .animation(.easeInOut, value: viewModel.showToast)
    }

    // MARK: - Subviews

    private var fields: some View {
        VStack(spacing: 16) {
            AppTextField(title: "Name", placeholder: "Enter customer name", text: $viewModel.name)
            AppTextField(title: "Phone", placeholder: "Enter 10 digit phone number", text: $viewModel.phone)
                .keyboardType(.phonePad)
            AppTextField(title: "Address", placeholder: "Enter address", text: $viewModel.address)
            AppTextField(title: "Notes (optional)", placeholder: "Add a note", text: $viewModel.notes, lineLimit: 2...4)
        }
    }
}
