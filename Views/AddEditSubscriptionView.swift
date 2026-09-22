import SwiftUI

// MARK: - Mode

enum AddEditMode {
    case add
    case edit(Subscription)
    case template(Subscription)

    var title: String {
        switch self {
        case .add:      return "New Subscription"
        case .edit:     return "Edit Subscription"
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
    @State private var name         = ""
    @State private var price        = ""
    @State private var billingCycle = BillingCycle.monthly
    @State private var nextDate     = Date()
    @State private var category     = SubscriptionCategory.other
    @State private var icon         = "📦"
    @State private var colorHex     = "7C3AED"
    @State private var notes        = ""
    @State private var accountName  = ""

    private let suggestedEmojis: [String] = [
        "📺","🎬","🎵","🎮","💪","📰","☁️","📦","🖥️","🎯",
        "🍎","🚀","💡","📱","🌐","🔒","📊","🗓️","💳","🌍","🎨","⚡️"
    ]

    private var accentColor: Color {
        Color(hex: colorHex) ?? AppTheme.accentPurple
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(price.replacingOccurrences(of: ",", with: ".")) != nil
    }

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
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Live preview card
                        previewCard.padding(.horizontal, 20)

                        // Details
                        formSection(title: "Details", icon: "info.circle.fill") {
                            VStack(spacing: 0) {
                                TextField("Name (e.g. Netflix)", text: $name)
                                    .autocapitalization(.words)
                                    .foregroundColor(AppTheme.textPrimary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)

                                Divider().background(AppTheme.border)

                                HStack {
                                    Text(manager.currencySymbol)
                                        .foregroundColor(AppTheme.textSecondary)
                                        .padding(.leading, 16)
                                    TextField("Price", text: $price)
                                        .keyboardType(.decimalPad)
                                        .foregroundColor(AppTheme.textPrimary)
                                        .padding(.vertical, 14)
                                        .padding(.trailing, 16)
                                }
                            }
                        }

                        // Account
                        formSection(title: "Account", icon: "folder.fill") {
                            VStack(spacing: 0) {
                                TextField("Account (e.g. Personal)", text: $accountName)
                                    .autocapitalization(.words)
                                    .foregroundColor(AppTheme.textPrimary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)

                                if !manager.uniqueAccounts.isEmpty {
                                    Divider().background(AppTheme.border)
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(manager.uniqueAccounts, id: \.self) { acc in
                                                Button { accountName = acc } label: {
                                                    Text(acc)
                                                        .font(.caption.bold())
                                                        .padding(.horizontal, 12)
                                                        .padding(.vertical, 6)
                                                        .background(accountName == acc
                                                                    ? accentColor
                                                                    : AppTheme.surface)
                                                        .foregroundColor(accountName == acc ? .white : AppTheme.textSecondary)
                                                        .clipShape(Capsule())
                                                        .overlay(Capsule().stroke(AppTheme.border, lineWidth: 1))
                                                }
                                                .buttonStyle(BorderlessButtonStyle())
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                    }
                                }
                            }
                        }

                        // Billing
                        formSection(title: "Billing", icon: "calendar") {
                            VStack(spacing: 0) {
                                HStack {
                                    Text("Billing Cycle")
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.textSecondary)
                                    Spacer()
                                    Picker("Billing Cycle", selection: $billingCycle) {
                                        ForEach(BillingCycle.allCases, id: \.self) {
                                            Text($0.rawValue).tag($0)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(accentColor)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)

                                Divider().background(AppTheme.border)

                                DatePicker("Next Billing Date", selection: $nextDate, displayedComponents: .date)
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                                    .tint(accentColor)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                            }
                        }

                        // Category
                        formSection(title: "Category", icon: "tag.fill") {
                            HStack {
                                Text("Category")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                                Spacer()
                                Picker("Category", selection: $category) {
                                    ForEach(SubscriptionCategory.allCases, id: \.self) { cat in
                                        Text(cat.emoji + " " + cat.rawValue).tag(cat)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(accentColor)
                                .onChange(of: category) { newCat in
                                    icon = newCat.emoji
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }

                        // Appearance
                        formSection(title: "Appearance", icon: "paintpalette.fill") {
                            VStack(alignment: .leading, spacing: 16) {
                                // Icon grid
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Icon")
                                        .font(.caption.bold())
                                        .foregroundColor(AppTheme.textSecondary)
                                        .padding(.horizontal, 16)

                                    LazyVGrid(
                                        columns: Array(repeating: GridItem(.flexible()), count: 6),
                                        spacing: 8
                                    ) {
                                        ForEach(suggestedEmojis, id: \.self) { emoji in
                                            Text(emoji)
                                                .font(.title2)
                                                .frame(width: 44, height: 44)
                                                .background(icon == emoji ? accentColor.opacity(0.18) : Color.clear)
                                                .cornerRadius(10)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(icon == emoji ? accentColor : Color.clear, lineWidth: 1.5)
                                                )
                                                .scaleEffect(icon == emoji ? 1.14 : 1.0)
                                                .animation(.spring(response: 0.28, dampingFraction: 0.58), value: icon)
                                                .onTapGesture { icon = emoji }
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                }

                                Divider().background(AppTheme.border)

                                // Color swatches
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Color")
                                        .font(.caption.bold())
                                        .foregroundColor(AppTheme.textSecondary)
                                        .padding(.horizontal, 16)

                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(presetColors, id: \.hex) { preset in
                                                ZStack {
                                                    Circle()
                                                        .fill(Color(hex: preset.hex) ?? .blue)
                                                        .frame(width: 36, height: 36)
                                                    if colorHex == preset.hex {
                                                        Image(systemName: "checkmark")
                                                            .font(.system(size: 13, weight: .bold))
                                                            .foregroundColor(.white)
                                                    }
                                                }
                                                .shadow(
                                                    color: (Color(hex: preset.hex) ?? .blue).opacity(colorHex == preset.hex ? 0.5 : 0),
                                                    radius: 6, x: 0, y: 3
                                                )
                                                .scaleEffect(colorHex == preset.hex ? 1.18 : 1.0)
                                                .animation(.spring(response: 0.28, dampingFraction: 0.6), value: colorHex)
                                                .onTapGesture { colorHex = preset.hex }
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.bottom, 4)
                                    }
                                }
                                .padding(.bottom, 4)
                            }
                            .padding(.top, 14)
                        }

                        // Notes
                        formSection(title: "Notes", icon: "note.text") {
                            TextEditor(text: $notes)
                                .frame(minHeight: 80)
                                .foregroundColor(AppTheme.textPrimary)
                                .onAppear { UITextView.appearance().backgroundColor = .clear }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                        }

                        // Save button
                        Button(action: save) {
                            Text("Save Subscription")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: AppTheme.radiusMd)
                                            .fill(Color.gray.opacity(0.3))
                                        if canSave {
                                            RoundedRectangle(cornerRadius: AppTheme.radiusMd)
                                                .fill(AppTheme.accentGradient)
                                        }
                                    }
                                )
                        }
                        .disabled(!canSave)
                        .padding(.horizontal, 20)
                        .shadow(color: canSave ? AppTheme.accentPurple.opacity(0.4) : .clear,
                                radius: 12, x: 0, y: 6)

                        Color.clear.frame(height: 40)
                    }
                    .padding(.top, 8)
                }
                .onTapGesture { hideKeyboard() }
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .onAppear { prepopulate() }
    }

    // MARK: - Live Preview Card

    private var previewCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(accentColor.opacity(0.55), lineWidth: 2)
                    .frame(width: 54, height: 54)
                Circle()
                    .fill(accentColor.opacity(0.13))
                    .frame(width: 50, height: 50)
                Text(icon)
                    .font(.system(size: 24))
            }
            .animation(.easeInOut(duration: 0.15), value: colorHex)
            .animation(.easeInOut(duration: 0.15), value: icon)

            VStack(alignment: .leading, spacing: 4) {
                Text(name.isEmpty ? "Subscription Name" : name)
                    .font(.headline)
                    .foregroundColor(name.isEmpty ? AppTheme.textTertiary : AppTheme.textPrimary)
                Text("\(category.emoji) \(category.rawValue)")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(price.isEmpty ? "–" : "\(manager.currencySymbol)\(price)")
                    .font(.headline.bold())
                    .foregroundColor(price.isEmpty ? AppTheme.textTertiary : AppTheme.textPrimary)
                Text(billingCycle.abbreviation)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                .fill(accentColor.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                        .stroke(accentColor.opacity(0.28), lineWidth: 1)
                )
        )
    }

    // MARK: - Form Section Builder

    private func formSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption.bold())
                    .foregroundColor(AppTheme.accentPurple)
                Text(title)
                    .font(.caption.bold())
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.horizontal, 20)

            content()
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                        .fill(AppTheme.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                                .stroke(AppTheme.border, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
        }
    }

    // MARK: - Logic

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
            accountName: accountName.trimmingCharacters(in: .whitespaces).isEmpty
                ? nil : accountName.trimmingCharacters(in: .whitespaces),
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
