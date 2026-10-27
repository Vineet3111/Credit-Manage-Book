//
//  DetailsView.swift
//  Credit Manage Book
//

import SwiftUI
import SwiftData

struct DetailsView: View {
    @Query(filter: #Predicate<Customer> { !$0.credits.isEmpty }, sort: \Customer.name)
    private var customers: [Customer]
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = DetailsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            CustomNavBar(title: "Details")
            ScrollView {
                LazyVStack(spacing: 12) {
                    if customers.isEmpty {
                        Text("No credits yet.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.top, 24)
                    }
                    ForEach(customers) { customer in
                        Button { viewModel.select(customer) } label: {
                            customerCard(customer)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .background(Color("BackgroundSc"))
        .sheet(item: $viewModel.selectedCustomer) { customer in
            creditsSheet(for: customer)
        }
    }

    // MARK: - Subviews

    private func customerCard(_ customer: Customer) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                CustomImage(name: customer.name)
                VStack(alignment: .leading, spacing: 2) {
                    Text(customer.name)
                        .font(.headline)
                    Text(customer.phone)
                        .font(.subheadline)
                    Text(customer.address)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(customer.credits.count == 1 ? "1 credit" : "\(customer.credits.count) credits")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.indigo)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.indigo.opacity(0.12), in: Capsule())
            }
            Divider()
            HStack {
                amountColumn(title: "TOTAL", amount: customer.totalCredit, color: .primary)
                amountColumn(title: "PAID", amount: customer.totalPaid, color: .green)
                amountColumn(title: "REMAINING",amount: customer.outstanding,color: customer.outstanding > 0   ?.red : .green)
            }
        }
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private func amountColumn(title: String, amount: Decimal, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(amount.inrFormatted)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func creditsSheet(for customer: Customer) -> some View {
        ScrollView {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    CustomImage(name: customer.name)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(customer.name)
                            .font(.headline)
                        Text(customer.address)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.bottom, 4)
                paymentCard(for: customer)
                ForEach(viewModel.sortedCredits(for: customer)) { credit in
                    creditCard(credit)
                }
            }
            .padding()
            .padding(.top, 12)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(.systemGroupedBackground))
        .overlay(alignment: .bottom) {
            if viewModel.showToast {
                ToastView(message: "Payment saved", isPresented: $viewModel.showToast)
            }
        }
        .animation(.easeInOut, value: viewModel.showToast)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func paymentCard(for customer: Customer) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("REMAINING BALANCE")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(customer.outstanding.inrFormatted)
                    .font(.headline)
                    .foregroundStyle(customer.outstanding > 0 ? Color.red : Color.green)
            }
            Divider()
            AppTextField(
                title: "PAID AMOUNT",
                placeholder: "Enter amount paid by customer",
                text: $viewModel.paymentAmount,
                fieldBackground: Color(.systemGroupedBackground)
            )
            .keyboardType(.decimalPad)
            if viewModel.isPaymentTooHigh {
                Text("Paid amount cannot be more than the remaining balance.")
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
            if let message = viewModel.errorMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
            AppButton(title: "Save Payment", isDisabled: !viewModel.canSavePayment(for: customer)) {
                viewModel.savePayment(for: customer, in: modelContext)
            }
        }
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private func creditCard(_ credit: Credit) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(credit.date.formatted(date: .abbreviated, time: .shortened))
                .font(.subheadline.weight(.semibold))
            Divider()
            ForEach(credit.items) { item in
                itemRow(item)
            }
            Divider()
            HStack {
                amountColumn(title: "TOTAL", amount: credit.total, color: .primary)
                amountColumn(title: "PAID", amount: credit.paid, color: .green)
                amountColumn(
                    title: "REMAINING",
                    amount: credit.outstanding,
                    color: credit.outstanding > 0 ? .red : .green
                )
            }
        }
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private func itemRow(_ item: CreditItem) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.productName)
                    .font(.subheadline.weight(.medium))
                Text("\(item.quantity) \(item.unit.title()) × \(item.pricePerUnit.inrFormatted)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(item.totalPrice.inrFormatted)
                .font(.subheadline.weight(.semibold))
        }
    }
}
