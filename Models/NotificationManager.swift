import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    func scheduleNotification(for subscription: Subscription) {
        // Cancel any existing notification for this subscription
        cancelNotification(for: subscription.id.uuidString)

        let content = UNMutableNotificationContent()
        content.title = "Subscription Due Soon"
        content.body = "Your \(subscription.name) subscription (\(subscription.billingCycle.abbreviation)) is due on \(subscription.nextBillingDate.formatted(date: .abbreviated, time: .omitted))."
        content.sound = .default

        let daysBefore = UserDefaults.standard.integer(forKey: "reminderDaysBefore")
        // Default to 1 day if not set but key might be missing (0)
        let actualDaysBefore = UserDefaults.standard.object(forKey: "reminderDaysBefore") == nil ? 1 : daysBefore
        
        let hour = UserDefaults.standard.integer(forKey: "reminderHour")
        let actualHour = UserDefaults.standard.object(forKey: "reminderHour") == nil ? 9 : hour
        
        let minute = UserDefaults.standard.integer(forKey: "reminderMinute")
        let actualMinute = UserDefaults.standard.object(forKey: "reminderMinute") == nil ? 0 : minute

        // Schedule for X days before
        guard var fireDate = Calendar.current.date(byAdding: .day, value: -actualDaysBefore, to: subscription.nextBillingDate) else { return }
        
        // Set specific time of day
        fireDate = Calendar.current.date(bySettingHour: actualHour, minute: actualMinute, second: 0, of: fireDate) ?? fireDate

        // If the fire date is in the past, don't schedule
        if fireDate < Date() { return }

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: subscription.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }

    func cancelNotification(for identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func scheduleAllNotifications(for subscriptions: [Subscription]) {
        cancelAllNotifications()
        for subscription in subscriptions {
            scheduleNotification(for: subscription)
        }
    }
}
