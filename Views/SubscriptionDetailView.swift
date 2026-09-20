import SwiftUI

struct SubscriptionDetailView: View {
    @EnvironmentObject var manager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    let subscription: Subscription

    @State private var showingEdit  = false
    @State private var showingDelete = false

    private var accent: Color {
        Color(hex: subscription.colorHex) ?? .blue
    }

    private var upcomingDates: [Date] {
        var dates: [Date] = []
        var date = subscription.nextBillingDate
        for _ in 0..<5 {
            dates.append(date)
            date = nextDate(after: date)
        }
        return dates
    }

    var body: some View {
        List {
            // Header
            Section {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(accent.opacity(0.15))
                            .frame(width: 80, height: 80)
                        Text(subscription.icon)
                            .font(.system(size: 40))
                    }
                    
                    Text(subscription.name)
                        .font(.title2)
                        .bold()
                    
                    Text(subscription.category.rawValue)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .listRowBackground(Color.clear)
            }
            
            // Details
            Section(header: Text("Details")) {
                detailRow(label: "Price", value: "\(manager.currencySymbol)\(String(format: "%.2f", subscription.price)) \(subscription.billingCycle.abbreviation)")
                detailRow(label: "Monthly Equivalent", value: "\(manager.currencySymbol)\(String(format: "%.2f", subscription.monthlyCost))")
                detailRow(label: "Billing Cycle", value: subscription.billingCycle.rawValue)
                
                if let account = subscription.accountName, !account.isEmpty {
                    detailRow(label: "Account", value: account)
                }
                
                HStack {
                    Text("Next Billing")
                    Spacer()
                    Text(subscription.nextBillingDate.formatted(date: .long, time: .omitted))
                        .foregroundColor(subscription.isDueSoon ? .red : .primary)
                }
            }
            
            // Timeline
            Section(header: Text("Upcoming Payments")) {
                ForEach(Array(upcomingDates.enumerated()), id: \.offset) { idx, date in
                    HStack {
                        Text(idx == 0 ? "Next" : "\(idx + 1)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(width: 40, alignment: .leading)
                        
                        Text(date.formatted(date: .long, time: .omitted))
                        
                        Spacer()
                        
                        Text("\(manager.currencySymbol)\(String(format: "%.2f", subscription.price))")
                            .foregroundColor(idx == 0 ? .primary : .secondary)
                            .bold(idx == 0)
                    }
                }
            }
            
            // Notes
            if !subscription.notes.isEmpty {
                Section(header: Text("Notes")) {
                    Text(subscription.notes)
                        .foregroundColor(.primary)
                }
            }
            
            // Actions
            Section {
                Button("Edit Subscription") {
                    showingEdit = true
                }
                .foregroundColor(.blue)
                
                Button("Delete Subscription") {
                    showingDelete = true
                }
                .foregroundColor(.red)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEdit) {
            AddEditSubscriptionView(mode: .edit(subscription))
        }
        .alert("Delete Subscription", isPresented: $showingDelete) {
            Button("Delete", role: .destructive) {
                manager.delete(subscription)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \"\(subscription.name)\"?")
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }

    private func nextDate(after date: Date) -> Date {
        var components = DateComponents()
        switch subscription.billingCycle {
        case .weekly:  components.day = 7
        case .monthly: components.month = 1
        case .yearly:  components.year = 1
        }
        return Calendar.current.date(byAdding: components, to: date) ?? date
    }
}
