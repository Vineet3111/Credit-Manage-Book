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
        VStack(spacing: 0) {
            // Header with customer info
            VStack(spacing: 16) {
                // Drag indicator area
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)
                
                // Customer header card
                HStack(spacing: 14) {
                    CustomImage(name: customer.name, size: 56)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(customer.name)
                            .font(.title3.bold())
                        Text(customer.phone)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(customer.address)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                // Summary stats
                HStack(spacing: 12) {
                    summaryStatBox(
                        title: "Total Credit",
                        amount: customer.totalCredit,
                        icon: "cart.fill",
                        color: .blue
                    )
                    summaryStatBox(
                        title: "Paid",
                        amount: customer.totalPaid,
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    summaryStatBox(
                        title: "Balance",
                        amount: customer.outstanding,
                        icon: customer.outstanding > 0 ? "clock.fill" : "checkmark.seal.fill",
                        color: customer.outstanding > 0 ? .red : .green
                    )
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 16)
            .background(Color(.systemBackground))
            
            // Scrollable content
            ScrollView {
                VStack(spacing: 16) {
                    paymentCard(for: customer)
                    
                    // Credits section header
                    if !viewModel.sortedCredits(for: customer).isEmpty {
                        HStack {
                            Text("Credit History")
                                .font(.headline)
                            Spacer()
                            Text("\(customer.credits.count) \(customer.credits.count == 1 ? "transaction" : "transactions")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                    }
                    
                    ForEach(viewModel.sortedCredits(for: customer)) { credit in
                        creditCard(credit)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.systemGroupedBackground))
        }
        .background(Color(.systemGroupedBackground))
        .overlay(alignment: .bottom) {
            if viewModel.showToast {
                ToastView(message: "Payment saved", isPresented: $viewModel.showToast)
            }
        }
        .animation(.easeInOut, value: viewModel.showToast)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }
    
    private func summaryStatBox(title: String, amount: Decimal, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(amount.inrFormatted)
                .font(.headline)
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }

    private func paymentCard(for customer: Customer) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with balance
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Make Payment")
                        .font(.headline)
                    Text("Current Balance")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(customer.outstanding.inrFormatted)
                        .font(.title2.bold())
                        .foregroundStyle(customer.outstanding > 0 ? Color.red : Color.green)
                    if customer.outstanding > 0 {
                        Text("Due")
                            .font(.caption2)
                            .foregroundStyle(.red)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.12), in: Capsule())
                    } else {
                        Text("Settled")
                            .font(.caption2)
                            .foregroundStyle(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.12), in: Capsule())
                    }
                }
            }
            
            Divider()
            
            // Payment input
            AppTextField(
                title: "PAID AMOUNT",
                placeholder: "Enter amount paid by customer",
                text: $viewModel.paymentAmount,
                fieldBackground: Color(.systemGroupedBackground)
            )
            .keyboardType(.decimalPad)
            
            if viewModel.isPaymentTooHigh {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                    Text("Paid amount cannot exceed the remaining balance.")
                        .font(.footnote)
                }
                .foregroundStyle(.red)
            }
            if let message = viewModel.errorMessage {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                    Text(message)
                        .font(.footnote)
                }
                .foregroundStyle(.red)
            }
            
            AppButton(title: "Save Payment", isDisabled: !viewModel.canSavePayment(for: customer)) {
                viewModel.savePayment(for: customer, in: modelContext)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.indigo.opacity(0.05), Color.purple.opacity(0.03)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 16)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.indigo.opacity(0.1), lineWidth: 1)
        )
    }

    private func creditCard(_ credit: Credit) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // Date header with status badge
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundStyle(.indigo)
                    Text(credit.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline.weight(.semibold))
                }
                Spacer()
                if credit.outstanding > 0 {
                    Text("Pending")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.12), in: Capsule())
                } else {
                    Text("Paid")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.12), in: Capsule())
                }
            }
            
            Divider()
            
            // Items section
            VStack(spacing: 10) {
                ForEach(credit.items) { item in
                    itemRow(item)
                }
            }
            
            Divider()
            
            // Amounts summary with colored background boxes
            HStack(spacing: 10) {
                amountBox(title: "TOTAL", amount: credit.total, color: .blue)
                amountBox(title: "PAID", amount: credit.paid, color: .green)
                amountBox(
                    title: "DUE",
                    amount: credit.outstanding,
                    color: credit.outstanding > 0 ? .red : .green
                )
            }
        }
        .padding(18)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
    
    private func amountBox(title: String, amount: Decimal, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(amount.inrFormatted)
                .font(.subheadline.bold())
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(color.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
    }

    private func itemRow(_ item: CreditItem) -> some View {
        HStack(spacing: 12) {
            // Product icon
            Image(systemName: "cube.fill")
                .font(.caption)
                .foregroundStyle(.indigo.opacity(0.6))
                .frame(width: 32, height: 32)
                .background(Color.indigo.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 3) {
                Text(item.productName)
                    .font(.subheadline.weight(.medium))
                HStack(spacing: 4) {
                    Text("\(item.quantity)")
                        .font(.caption)
                    Text(item.unit.title())
                        .font(.caption2)
                    Text("×")
                        .font(.caption2)
                    Text(item.pricePerUnit.inrFormatted)
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(item.totalPrice.inrFormatted)
                .font(.subheadline.bold())
                .foregroundStyle(.primary)
        }
        .padding(10)
        .background(Color(.systemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
    }
}
