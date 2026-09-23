import SwiftUI

struct NotificationSettingsView: View {
    @AppStorage("reminderDaysBefore") private var reminderDaysBefore = 1
    @AppStorage("reminderHour") private var reminderHour = 9
    @AppStorage("reminderMinute") private var reminderMinute = 0
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var manager: SubscriptionManager

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        Text("Notifications")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.leading, 8)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "bell.fill")
                                .font(.caption.bold())
                                .foregroundColor(AppTheme.accentPurple)
                            Text("Reminder Timing")
                                .font(.caption.bold())
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            HStack {
                                Text("Remind Me")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                                Picker("Remind Me", selection: $reminderDaysBefore) {
                                    Text("On Due Date").tag(0)
                                    Text("1 Day Before").tag(1)
                                    Text("2 Days Before").tag(2)
                                    Text("3 Days Before").tag(3)
                                    Text("1 Week Before").tag(7)
                                }
                                .pickerStyle(.menu)
                                .tint(AppTheme.accentPurple)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            
                            Divider().background(AppTheme.border)
                            
                            HStack {
                                Text("Time of Day")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                                
                                DatePicker("", selection: Binding(
                                    get: {
                                        var comps = DateComponents()
                                        comps.hour = reminderHour
                                        comps.minute = reminderMinute
                                        return Calendar.current.date(from: comps) ?? Date()
                                    },
                                    set: { newDate in
                                        let comps = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                                        reminderHour = comps.hour ?? 9
                                        reminderMinute = comps.minute ?? 0
                                    }
                                ), displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .tint(AppTheme.accentPurple)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                                .fill(AppTheme.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                                        .stroke(AppTheme.border, lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                        
                        Text("Changes to these settings will automatically reschedule all your upcoming reminders.")
                            .font(.caption)
                            .foregroundColor(AppTheme.textTertiary)
                            .padding(.horizontal, 24)
                            .padding(.top, 4)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onChange(of: reminderDaysBefore) { _ in rescheduleAll() }
        .onChange(of: reminderHour) { _ in rescheduleAll() }
        .onChange(of: reminderMinute) { _ in rescheduleAll() }
    }
    
    private func rescheduleAll() {
        NotificationManager.shared.scheduleAllNotifications(for: manager.activeSubscriptions)
    }
}
