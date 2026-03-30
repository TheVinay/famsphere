//
//  NotificationManager.swift
//  FamSphere
//
//  Created by Vinays Mac on 1/19/26.
//

import Foundation
import UserNotifications
import SwiftData
import Combine

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        await checkAuthorizationStatus()
        return granted
    }
    
    func checkAuthorizationStatus() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }
    
    // MARK: - Event Reminders
    
    func scheduleEventReminder(
        eventId: String,
        title: String,
        eventDate: Date,
        minutesBefore: Int
    ) async throws {
        let center = UNUserNotificationCenter.current()
        
        // Calculate notification date
        let notificationDate = eventDate.addingTimeInterval(-Double(minutesBefore * 60))
        
        // Don't schedule if notification date is in the past
        guard notificationDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Event"
        content.body = title
        content.sound = .default
        content.categoryIdentifier = "EVENT_REMINDER"
        
        // Create date components for trigger
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: notificationDate
        )
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = "event_\(eventId)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        try await center.add(request)
    }
    
    func removeEventReminder(eventId: String) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["event_\(eventId)"])
    }
    
    // MARK: - Chat Message Notifications
    
    func scheduleMessageNotification(
        messageId: String,
        authorName: String,
        content: String,
        currentUserName: String
    ) async throws {
        // Don't notify if the user sent the message themselves
        guard authorName != currentUserName else { return }
        
        let center = UNUserNotificationCenter.current()
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "New message from \(authorName)"
        notificationContent.body = content
        notificationContent.sound = .default
        notificationContent.categoryIdentifier = "CHAT_MESSAGE"
        
        // Immediate trigger with slight delay to avoid notification while app is active
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let identifier = "message_\(messageId)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: notificationContent,
            trigger: trigger
        )
        
        try await center.add(request)
    }
    
    // MARK: - Badge Management
    
    func updateBadgeCount(_ count: Int) {
        UNUserNotificationCenter.current().setBadgeCount(count)
    }
    
    func clearBadge() {
        updateBadgeCount(0)
    }
}

// MARK: - Reminder Options

enum ReminderOption: Int, CaseIterable, Identifiable {
    case fifteenMinutes = 15
    case thirtyMinutes = 30
    case oneHour = 60
    case twoHours = 120
    case oneDay = 1440
    
    var id: Int { rawValue }
    
    var displayName: String {
        switch self {
        case .fifteenMinutes:
            return "15 minutes before"
        case .thirtyMinutes:
            return "30 minutes before"
        case .oneHour:
            return "1 hour before"
        case .twoHours:
            return "2 hours before"
        case .oneDay:
            return "1 day before"
        }
    }
}
