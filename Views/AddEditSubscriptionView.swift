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
        case .template: return "New Subscription"
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
    @State private var colorHex    = "6C63FF"
    @State private var notes       = ""

    @State private var showEmojiPicker = false

    // Common emoji picks per category
    private let suggestedEmojis: [String] = [
        "📺","🎬","🎵","🎮","💪","📰","☁️","📦","🖥️","🎯",
        "🍎","🚀","💡","📱","🌐","🔒","📊","🗓️","💳","🌍"
    ]

    private var existingId: UUID? {
        if case .edit(let sub) = mode { return sub.id }
        return nil
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        // Avatar preview
                        avatarPreview

                        // Form sections
                        formSection(title: "Details") {
                            customTextField("Name (e.g. Netflix)", text: $name)
                            customTextField("Price", text: $price, keyboardType: .decimalPad,
                                           leadingText: manager.currencySymbol)
                        }

                        formSection(title: "Billing") {
                            billingCycleSegment
                            datePicker
                        }

                        formSection(title: "Category") {
                            categoryPicker
                        }

                        formSection(title: "Icon") {
                            emojiGrid
                        }

                        formSection(title: "Colour") {
                            colorPalette
                        }

                        formSection(title: "Notes (optional)") {
                            customTextField("Add a note...", text: $notes)
                        }

                        // Save button
                        Button(action: save) {
                            Text(mode.title == "New Subscription" ? "Add Subscription" : "Save Changes")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal, 20)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || price.isEmpty)

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { prepopulate() }
    }

    // MARK: Avatar Preview

    private var avatarPreview: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: colorHex) ?? .accentIndigo,
                                 (Color(hex: colorHex) ?? .accentIndigo).opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 90, height: 90)
                .shadow(color: (Color(hex: colorHex) ?? .accentIndigo).opacity(0.5), radius: 20)

            Text(icon)
                .font(.system(size: 40))
        }
        .padding(.top, 8)
    }

    // MARK: Billing Cycle Segment

    private var billingCycleSegment: some View {
        HStack(spacing: 0) {
            ForEach(BillingCycle.allCases, id: \.self) { cycle in
                Button(action: { withAnimation { billingCycle = cycle } }) {
                    Text(cycle.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(billingCycle == cycle ? .white : .textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            billingCycle == cycle
                                ? AnyView(LinearGradient.heroGradient.cornerRadius(12))
                                : AnyView(Color.clear)
                        )
                }
            }
        }
        .padding(4)
        .background(Color.surfaceColor.cornerRadius(14))
    }

    // MARK: Date Picker

    private var datePicker: some View {
        HStack {
            Text("Next Billing Date")
                .font(.system(size: 15))
                .foregroundColor(.textSecondary)
            Spacer()
            DatePicker("", selection: $nextDate, displayedComponents: .date)
                .labelsHidden()
                .colorScheme(.dark)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: Category Picker

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(SubscriptionCategory.allCases, id: \.self) { cat in
                    Button(action: {
                        withAnimation(.spring()) {
                            category = cat
                            icon = cat.emoji
                        }
                    }) {
                        HStack(spacing: 6) {
                            Text(cat.emoji)
                            Text(cat.rawValue)
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(category == cat ? .white : .textSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(category == cat ? cat.accentColor : Color.surfaceColor)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    // MARK: Emoji Grid

    private var emojiGrid: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 5)
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(suggestedEmojis, id: \.self) { emoji in
                Button(action: { withAnimation { icon = emoji } }) {
                    Text(emoji)
                        .font(.system(size: 26))
                        .frame(width: 48, height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(icon == emoji
                                      ? Color(hex: colorHex)?.opacity(0.25) ?? Color.accentIndigo.opacity(0.25)
                                      : Color.surfaceColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(icon == emoji
                                                ? (Color(hex: colorHex) ?? .accentIndigo)
                                                : Color.clear, lineWidth: 2)
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: Color Palette

    private var colorPalette: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(presetColors, id: \.hex) { preset in
                    Button(action: { withAnimation { colorHex = preset.hex } }) {
                        Circle()
                            .fill(Color(hex: preset.hex) ?? .accentIndigo)
                            .frame(width: 38, height: 38)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: colorHex == preset.hex ? 3 : 0)
                            )
                            .shadow(color: (Color(hex: preset.hex) ?? .accentIndigo).opacity(0.5),
                                    radius: colorHex == preset.hex ? 8 : 0)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Helpers

    private func formSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.textMuted)
                .padding(.horizontal, 20)

            VStack(spacing: 1) {
                content()
            }
            .glassCard()
            .padding(.horizontal, 20)
        }
    }

    private func customTextField(
        _ placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        leadingText: String? = nil
    ) -> some View {
        HStack(spacing: 8) {
            if let lead = leadingText {
                Text(lead)
                    .foregroundColor(.textSecondary)
                    .font(.system(size: 16))
            }
            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .foregroundColor(.textPrimary)
                .font(.system(size: 16))
                .autocapitalization(.words)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
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
            notes: notes
        )

        if case .edit = mode {
            manager.update(sub)
        } else {
            manager.add(sub)
        }
        dismiss()
    }
}
