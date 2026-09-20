import SwiftUI

struct AddSubscriptionView: View {
    @EnvironmentObject var manager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var price = ""
    @State private var billingCycle = BillingCycle.monthly
    @State private var nextBillingDate = Date()
    @State private var color = Color.blue
    
    let availableColors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .gray, .black]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Subscription Name (e.g., Netflix)", text: $name)
                    
                    HStack {
                        Text("$")
                            .foregroundColor(.secondary)
                        TextField("Price", text: $price)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section(header: Text("Billing")) {
                    Picker("Billing Cycle", selection: $billingCycle) {
                        ForEach(BillingCycle.allCases, id: \.self) { cycle in
                            Text(cycle.rawValue).tag(cycle)
                        }
                    }
                    
                    DatePicker("Next Billing Date", selection: $nextBillingDate, displayedComponents: .date)
                }
                
                Section(header: Text("Appearance")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(availableColors, id: \.self) { colorOption in
                                Circle()
                                    .fill(colorOption)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: colorOption == color ? 3 : 0)
                                    )
                                    .onTapGesture {
                                        self.color = colorOption
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Add Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSubscription()
                    }
                    .disabled(name.isEmpty || price.isEmpty)
                }
            }
        }
    }
    
    private func saveSubscription() {
        guard let priceValue = Double(price.replacingOccurrences(of: ",", with: ".")) else { return }
        
        let newSubscription = Subscription(
            name: name,
            price: priceValue,
            billingCycle: billingCycle,
            nextBillingDate: nextBillingDate,
            colorHex: color.toHex() ?? "#0000FF"
        )
        
        manager.add(newSubscription)
        dismiss()
    }
}

// Extension to convert Color to Hex
extension Color {
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if a != Float(1.0) {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}
