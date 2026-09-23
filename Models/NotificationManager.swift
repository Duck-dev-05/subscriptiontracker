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

        // Schedule for 24 hours before
        guard let fireDate = Calendar.current.date(byAdding: .day, value: -1, to: subscription.nextBillingDate) else { return }

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
