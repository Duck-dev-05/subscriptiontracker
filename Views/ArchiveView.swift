import SwiftUI

struct ArchiveView: View {
    @EnvironmentObject var manager: SubscriptionManager

    var body: some View {
        List {
            if manager.archivedSubscriptions.isEmpty {
                Text("No archived subscriptions.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(manager.archivedSubscriptions) { sub in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(sub.icon)
                                Text(sub.name)
                                    .font(.headline)
                            }
                            Text("Archived")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Reactivate") {
                            var updated = sub
                            updated.isArchived = false
                            manager.update(updated)
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Archive")
    }
}
