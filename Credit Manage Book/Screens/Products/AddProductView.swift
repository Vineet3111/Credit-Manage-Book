//
//  AddProductView.swift
//  Credit Manage Book
//

import SwiftUI
import SwiftData

struct AddProductView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = AddProductViewModel()

    var body: some View {
        VStack(spacing: 0) {
            CustomNavBar(title: "Add Product")
            ScrollView {
                VStack(spacing: 16) {
                    fields
                    if let message = viewModel.errorMessage {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                    AppButton(
                        title: "Save",
                        isDisabled: !viewModel.canSave
                    ) {
                        viewModel.save(in: modelContext)
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
        .overlay(alignment: .bottom) {
            if viewModel.showToast {
                ToastView(message: "Product saved", isPresented: $viewModel.showToast)
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
}
