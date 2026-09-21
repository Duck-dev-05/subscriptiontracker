import SwiftUI

// MARK: - Mode

enum AddEditMode {
    case add
    case edit(Subscription)
    case template(Subscription)

    var title: String {
        switch self {
        case .add:  return "New Subscription"
        case .edit: return "Edit Subscription"
        case .template: return "Add Subscription"
        }
    }
}

// MARK: - View

struct AddEditSubscriptionView: View {
    @EnvironmentObject var manager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss

    let mode: AddEditMode

    // Fields
    @State private var name        = ""
    @State private var price       = ""
    @State private var billingCycle = BillingCycle.monthly
    @State private var nextDate    = Date()
    @State private var category    = SubscriptionCategory.other
    @State private var icon        = "📦"
    @State private var colorHex    = "007AFF" // Default blue
    @State private var notes       = ""
    @State private var accountName = ""

    private let suggestedEmojis: [String] = [
        "📺","🎬","🎵","🎮","💪","📰","☁️","📦","🖥️","🎯",
        "🍎","🚀","💡","📱","🌐","🔒","📊","🗓️","💳","🌍"
    ]

    private var existingId: UUID? {
        if case .edit(let sub) = mode { return sub.id }
        return nil
    }

    private var existingSub: Subscription? {
        if case .edit(let sub) = mode { return sub }
        return nil
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Name (e.g. Netflix)", text: $name)
                        .autocapitalization(.words)
                    
                    HStack {
                        Text(manager.currencySymbol)
                            .foregroundColor(.secondary)
                        TextField("Price", text: $price)
                            .keyboardType(.decimalPad)
                    }
                }

                Section(header: Text("Account")) {
                    TextField("Account (e.g. Personal)", text: $accountName)
                        .autocapitalization(.words)
                    
                    if !manager.uniqueAccounts.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(manager.uniqueAccounts, id: \.self) { acc in
                                    Button(action: { accountName = acc }) {
                                        Text(acc)
                                            .font(.caption)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(accountName == acc ? Color.blue : Color(uiColor: .systemGray5))
                                            .foregroundColor(accountName == acc ? .white : .primary)
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                        }
                    }
                }

                Section(header: Text("Billing")) {
                    Picker("Billing Cycle", selection: $billingCycle) {
                        ForEach(BillingCycle.allCases, id: \.self) { cycle in
                            Text(cycle.rawValue).tag(cycle)
                        }
                    }
                    DatePicker("Next Billing Date", selection: $nextDate, displayedComponents: .date)
                }

                Section(header: Text("Category")) {
                    Picker("Category", selection: $category) {
                        ForEach(SubscriptionCategory.allCases, id: \.self) { cat in
                            Text(cat.emoji + " " + cat.rawValue).tag(cat)
                        }
                    }
                    .onChange(of: category) { newCat in
                        icon = newCat.emoji
                    }
                }

                Section(header: Text("Appearance")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Icon")
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 10) {
                            ForEach(suggestedEmojis, id: \.self) { emoji in
                                Text(emoji)
                                    .font(.title)
                                    .padding(8)
                                    .background(icon == emoji ? Color.blue.opacity(0.2) : Color.clear)
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        icon = emoji
                                    }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Color")
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(presetColors, id: \.hex) { preset in
                                    Circle()
                                        .fill(Color(hex: preset.hex) ?? .blue)
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary, lineWidth: colorHex == preset.hex ? 3 : 0)
                                        )
                                        .onTapGesture {
                                            colorHex = preset.hex
                                        }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || price.isEmpty)
                }
            }
        }
        .onAppear { prepopulate() }
    }

    private func prepopulate() {
        switch mode {
        case .edit(let sub), .template(let sub):
            name         = sub.name
            price        = String(format: "%.2f", sub.price)
            billingCycle = sub.billingCycle
            nextDate     = sub.nextBillingDate
            category     = sub.category
            icon         = sub.icon
            colorHex     = sub.colorHex
            notes        = sub.notes
            accountName  = sub.accountName ?? ""
        case .add:
            break
        }
    }

    private func save() {
        guard let priceValue = Double(price.replacingOccurrences(of: ",", with: ".")) else { return }

        let sub = Subscription(
            id: existingId ?? UUID(),
            name: name.trimmingCharacters(in: .whitespaces),
            price: priceValue,
            billingCycle: billingCycle,
            nextBillingDate: nextDate,
            colorHex: colorHex,
            category: category,
            icon: icon,
            notes: notes,
            accountName: accountName.trimmingCharacters(in: .whitespaces).isEmpty ? nil : accountName.trimmingCharacters(in: .whitespaces),
            paymentHistory: existingSub?.paymentHistory ?? [],
            isArchived: existingSub?.isArchived ?? false
        )

        if case .edit = mode {
            manager.update(sub)
        } else {
            manager.add(sub)
        }
        dismiss()
    }
}
