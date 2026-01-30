//
//  NotificationManager.swift
//  75DeepSpaceBreath
//
//  Local notifications: "Time to breathe" (morning/evening, after session).
//

import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    
    private let morningId = "DSB_reminder_morning"
    private let eveningId = "DSB_reminder_evening"
    private let afterSessionId = "DSB_reminder_after_session"
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }
    
    func scheduleMorningReminder(hour: Int, minute: Int) {
        cancel(id: morningId)
        let content = UNMutableNotificationContent()
        content.title = "Deep Space Breath"
        content.body = "Time to breathe. Start your morning session."
        content.sound = .default
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: morningId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleEveningReminder(hour: Int, minute: Int) {
        cancel(id: eveningId)
        let content = UNMutableNotificationContent()
        content.title = "Deep Space Breath"
        content.body = "Time to breathe. Wind down with an evening session."
        content.sound = .default
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: eveningId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleAfterSessionReminder(hoursFromNow: Int) {
        cancel(id: afterSessionId)
        guard hoursFromNow > 0 else { return }
        let content = UNMutableNotificationContent()
        content.title = "Deep Space Breath"
        content.body = "Time to breathe again. Ready for another session?"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(hoursFromNow * 3600), repeats: false)
        let request = UNNotificationRequest(identifier: afterSessionId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancel(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [morningId, eveningId, afterSessionId])
    }
}
