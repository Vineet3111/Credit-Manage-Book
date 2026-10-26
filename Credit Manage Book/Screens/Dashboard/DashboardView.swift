//
//  DashboardView.swift
//  Credit Manage Book
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Customer.name) private var customers: [Customer]
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            ScrollView {
                VStack(spacing: 16) {
                    header
                    outstandingCard
                    actionButtons
                    customerList
                }
            }
            .background(Color(.systemGroupedBackground))
            
            .navigationDestination(for: DashboardRoute.self) { route in
                switch route {
                case .addCustomer: AddCustomerView()
                case .addCredit(let customer): AddCreditView(customer: customer)
                }
            }
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
        }
    }

    // MARK: - Subviews

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(viewModel.greeting()) 👋")
                    .font(.subheadline)
                Text("My Shop")
                    .font(.title.bold())
            }
            Spacer()
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.white.opacity(0.9))
        }
        .foregroundStyle(.white)
        .padding(.horizontal)
        .padding(.bottom, 56)
        .background(Color.indigo.padding(.top, -200))
    }

    private var outstandingCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("TOTAL OUTSTANDING")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(viewModel.totalOutstanding(for: customers).inrFormatted)
                    .font(.title.bold())
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: "clock")
                .foregroundStyle(.red)
                .padding(10)
                .background(.red.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .padding(.top, -56)
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            actionButton(title: "Add Customer", isFilled: false, action: viewModel.addCustomerTapped)
            actionButton(title: "Add Credit", isFilled: true) { viewModel.addCreditTapped() }
        }
        .padding(.horizontal)
    }

    private func actionButton(title: String, isFilled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "plus")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(isFilled ? Color.white.opacity(0.25) : Color.indigo, in: Circle())
                Text(title)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(isFilled ? Color.white : Color.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isFilled ? Color.indigo : Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private var customerList: some View {
        LazyVStack(spacing: 10) {
            if customers.isEmpty {
                Text("No customers yet. Tap Add Customer to start.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 24)
            }
            ForEach(customers) { customer in
                customerRow(customer)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 24)
    }

    private func customerRow(_ customer: Customer) -> some View {
        HStack(spacing: 12) {
            CustomImage(name: customer.name)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(customer.name)
                    .font(.headline)
                Text(customer.phone)
                    .font(.subheadline)
                Text(customer.address)
                    .font(.caption).foregroundStyle(.secondary)
                
            }
            Spacer()
            VStack(spacing: 10) {
                Button { viewModel.deleteTapped(customer) } label: {
                    Image(systemName: "trash").foregroundStyle(.red)
                }
                Button { viewModel.addCreditTapped(for: customer) } label: {
                    Image(systemName: "plus").foregroundStyle(.indigo)
                }
            }
        }
        .padding(12)
        .background(.background, in: RoundedRectangle(cornerRadius: 14))
    }
}
