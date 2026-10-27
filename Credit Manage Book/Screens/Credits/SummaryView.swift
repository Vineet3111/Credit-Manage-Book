//
//  SummaryView.swift
//  Credit Manage Book
//

import SwiftUI
import SwiftData

struct SummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel: AddCreditViewModel

    var body: some View {
        VStack(spacing: 0) {
            CustomNavBar(title: "Summary") { dismiss() }
            ScrollView {
                VStack(spacing: 16) {
                    customerCard
                    itemsCard
                    totalsCard
                    if let message = viewModel.errorMessage {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                    AppButton(title: "Save Credit", isDisabled: !viewModel.isPaidAmountValid) {
                        viewModel.saveCredit(in: modelContext)
                    }
                }
                .padding()
            }
        }
        .background(Color("BackgroundSc"))
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Subviews

    private var customerCard: some View {
        HStack(spacing: 12) {
            CustomImage(name: viewModel.selectedCustomer?.name ?? "")
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.selectedCustomer?.name ?? "")
                    .font(.headline)
                Text(viewModel.selectedCustomer?.phone ?? "")
                    .font(.subheadline)
                Text(viewModel.selectedCustomer?.address ?? "")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private var itemsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Items")
                .font(.headline)
            Divider()
            ForEach(viewModel.items) { item in
                itemRow(item)
            }
        }
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private func itemRow(_ item: CreditItemDraft) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.productName)
                    .font(.subheadline.weight(.medium))
                Text("\(item.quantity) \(item.unit.title()) × \(item.price.inrFormatted)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(item.totalAmount.inrFormatted)
                .font(.subheadline.weight(.semibold))
        }
    }

    private var totalsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("GRAND TOTAL")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(viewModel.grandTotal.inrFormatted)
                    .font(.title3.bold())
            }
            Divider()
            AppTextField(
                title: "PAID AMOUNT",
                placeholder: "Enter amount paid now",
                text: $viewModel.paidAmount,
                fieldBackground: Color(.systemGroupedBackground)
            )
            .keyboardType(.decimalPad)
            if !viewModel.isPaidAmountValid {
                Text("Paid amount cannot be more than the grand total.")
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
            HStack {
                Text("REMAINING BALANCE")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(viewModel.remainingAmount.inrFormatted)
                    .font(.headline)
                    .foregroundStyle(viewModel.remainingAmount > 0 ? Color.red : Color.green)
            }
        }
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}
