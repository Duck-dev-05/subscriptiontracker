import SwiftUI

struct CategoryManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var manager: SubscriptionManager
    
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    @State private var newCategoryEmoji = "📦"
    
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
                        
                        // Default Categories List
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Default Categories")
                                .font(.caption.bold())
                                .foregroundColor(AppTheme.textSecondary)
                            
                            ForEach(SubscriptionCategory.defaultCases) { category in
                                CategoryRow(category: category, isCustom: false)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Custom Categories List
                        if !manager.customCategories.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Custom Categories")
                                    .font(.caption.bold())
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                ForEach(manager.customCategories) { category in
                                    CategoryRow(category: category, isCustom: true) {
                                        manager.customCategories.removeAll { $0.id == category.id }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Add Button
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
            .sheet(isPresented: $showingAddCategory) {
                AddCategorySheet(name: $newCategoryName, emoji: $newCategoryEmoji) {
                    let newCat = SubscriptionCategory(rawValue: newCategoryName, emoji: newCategoryEmoji)
                    manager.customCategories.append(newCat)
                    newCategoryName = ""
                    newCategoryEmoji = "📦"
                    showingAddCategory = false
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct AddCategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var name: String
    @Binding var emoji: String
    var onSave: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    HStack {
                        TextField("Emoji", text: $emoji)
                            .font(.system(size: 30))
                            .frame(width: 60, height: 60)
                            .multilineTextAlignment(.center)
                            .background(.ultraThinMaterial)
                                .environment(\.colorScheme, .dark)
                            .cornerRadius(12)
                        
                        TextField("Category Name", text: $name)
                            .font(.headline)
                            .padding()
                            .background(.ultraThinMaterial)
                                .environment(\.colorScheme, .dark)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    Spacer()
                }
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

struct CategoryRow: View {
    let category: SubscriptionCategory
    let isCustom: Bool
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                                .environment(\.colorScheme, .dark)
                    .frame(width: 44, height: 44)
                
                Text(category.emoji)
                    .font(.system(size: 20))
            }
            
            Text(category.rawValue)
                .font(.subheadline.bold())
                .foregroundColor(AppTheme.textPrimary)
            
            Spacer()
            
            if isCustom {
                Button {
                    onDelete?()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.radiusMd)
                .fill(.ultraThinMaterial)
                                .environment(\.colorScheme, .dark)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.radiusMd)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
        )
    }
}
