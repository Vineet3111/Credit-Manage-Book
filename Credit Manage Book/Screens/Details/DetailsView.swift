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
                        emptyState
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
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.secondary.opacity(0.5))
            
            Text("No Credit Records Yet")
                .font(.title3.bold())
            
            Text("Credits will appear here once you\nadd them for your customers")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }

    private func customerCard(_ customer: Customer) -> some View {
        HStack(spacing: 0) {
            // Status accent bar
            RoundedRectangle(cornerRadius: 0)
                .fill(customer.outstanding > 0 ? Color.red : Color.green)
                .frame(width: 5)
            
            // Main content
            HStack(spacing: 14) {
                CustomImage(name: customer.name, size: 52)
                
                VStack(alignment: .leading, spacing: 6) {
                    // Name and badge
                    HStack(spacing: 8) {
                        Text(customer.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Text("\(customer.credits.count)")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.indigo)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.indigo.opacity(0.12), in: Capsule())
                    }
                    
                    // Phone and address
                    VStack(alignment: .leading, spacing: 2) {
                        Text(customer.phone)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(customer.address)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Outstanding amount with arrow
                VStack(alignment: .trailing, spacing: 4) {
                    Text(customer.outstanding.inrFormatted)
                        .font(.headline.bold())
                        .foregroundStyle(customer.outstanding > 0 ? Color.red : Color.green)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    HStack(spacing: 4) {
                        if customer.outstanding > 0 {
                            Image(systemName: "clock.fill")
                                .font(.caption2)
                            Text("Due")
                                .font(.caption2.weight(.medium))
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                            Text("Paid")
                                .font(.caption2.weight(.medium))
                        }
                    }
                    .foregroundStyle(customer.outstanding > 0 ? Color.red : Color.green)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        (customer.outstanding > 0 ? Color.red : Color.green).opacity(0.12),
                        in: Capsule()
                    )
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary.opacity(0.5))
                        .padding(.top, 2)
                }
            }
            .padding(.vertical, 14)
            .padding(.leading, 12)
            .padding(.trailing, 14)
        }
        .background(
            ZStack {
                Color(.systemBackground)
                
                // Subtle gradient overlay based on status
                LinearGradient(
                    gradient: Gradient(colors: [
                        (customer.outstanding > 0 ? Color.red : Color.green).opacity(0.02),
                        Color.clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
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
                        
                        // Selectable phone number
                        HStack(spacing: 6) {
                            Image(systemName: "phone.fill")
                                .font(.caption)
                            Text(customer.phone)
                                .font(.subheadline)
                                .textSelection(.enabled)
                        }
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
                ToastView(message: viewModel.toastMessage, isPresented: $viewModel.showToast)
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
