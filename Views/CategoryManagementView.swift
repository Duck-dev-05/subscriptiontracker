import SwiftUI

struct CategoryManagementView: View {
    @Environment(\.dismiss) private var dismiss
    
    // In a fully dynamic version, these would be fetched from CoreData or UserDefaults
    @State private var categories = SubscriptionCategory.allCases.map { 
        CategoryItem(category: $0, isEnabled: true) 
    }
    
    @State private var showingAddCategory = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Personalize")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                                Text("Categories")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            Spacer()
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Info Card
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 12) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.title2)
                                    .foregroundColor(AppTheme.accentPurple)
                                Text("Manage your categories to keep your subscriptions organized your way.")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.radiusMd)
                                .fill(AppTheme.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.radiusMd)
                                        .stroke(AppTheme.border, lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                        
                        // Categories List
                        VStack(spacing: 12) {
                            ForEach($categories) { $item in
                                CategoryRow(item: $item)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Add Button Placeholder
                        Button {
                            showingAddCategory = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                Text("Add Custom Category")
                                    .font(.headline)
                            }
                            .foregroundColor(AppTheme.accentPurple)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.radiusMd)
                                    .strokeBorder(
                                        style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                                    )
                                    .foregroundColor(AppTheme.accentPurple.opacity(0.5))
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        Spacer().frame(height: 40)
                    }
                    .padding(.top, 10)
                }
            }
            .navigationBarHidden(true)
            .alert("Feature in Development", isPresented: $showingAddCategory) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Adding custom categories requires updating the local data model. This UI is ready for when that feature is implemented!")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CategoryItem: Identifiable {
    let id = UUID()
    let category: SubscriptionCategory
    var isEnabled: Bool
}

struct CategoryRow: View {
    @Binding var item: CategoryItem
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.surface)
                    .frame(width: 44, height: 44)
                
                Text(item.category.emoji)
                    .font(.system(size: 20))
            }
            
            Text(item.category.rawValue)
                .font(.subheadline.bold())
                .foregroundColor(item.isEnabled ? AppTheme.textPrimary : AppTheme.textTertiary)
            
            Spacer()
            
            Toggle("", isOn: $item.isEnabled)
                .labelsHidden()
                .tint(AppTheme.accentPurple)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.radiusMd)
                .fill(AppTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.radiusMd)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
        )
        .opacity(item.isEnabled ? 1.0 : 0.6)
    }
}
