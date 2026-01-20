//
//  Models.swift
//  FamSphere
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Helpers (CloudKit-safe array storage)

private func encodeJSON<T: Encodable>(_ value: T) -> Data {
    (try? JSONEncoder().encode(value)) ?? Data()
}

private func decodeJSON<T: Decodable>(_ type: T.Type, from data: Data) -> T? {
    try? JSONDecoder().decode(type, from: data)
}

// MARK: - Family Member

@Model
final class FamilyMember {
    var name: String
    var roleValue: String
    var colorHex: String

    init(name: String, role: MemberRole, colorHex: String) {
        self.name = name
        self.roleValue = role.rawValue
        self.colorHex = colorHex
    }
}

// MARK: - Family Member Extensions

extension FamilyMember {
    var role: MemberRole {
        get { MemberRole(rawValue: roleValue) ?? .parent }
        set { roleValue = newValue.rawValue }
    }
}

enum MemberRole: String, Codable, CaseIterable {
    case parent
    case child
}

// MARK: - Chat Message

@Model
final class ChatMessage {
    var content: String
    var timestamp: Date
    var authorName: String
    var isImportant: Bool
    var isPinned: Bool

    init(content: String, authorName: String, isImportant: Bool = false, isPinned: Bool = false) {
        self.content = content
        self.timestamp = Date()
        self.authorName = authorName
        self.isImportant = isImportant
        self.isPinned = isPinned
    }
}

// MARK: - Chat Message Extensions

extension ChatMessage {
    var isSystemMessage: Bool {
        authorName == "FamSphere"
    }
}

// MARK: - Calendar Event

@Model
final class CalendarEvent {
    var title: String
    var eventDate: Date
    var endDate: Date?
    var notes: String
    var eventTypeValue: String
    var createdByName: String
    var colorHex: String

    var isRecurring: Bool
    var recurrenceDaysData: Data
    var recurrenceEndDate: Date?
    var recurrenceGroupId: String?
    
    var reminderMinutesBefore: Int? // nil means no reminder

    init(
        title: String,
        eventDate: Date,
        endDate: Date? = nil,
        notes: String = "",
        eventType: EventType,
        createdByName: String,
        colorHex: String,
        isRecurring: Bool = false,
        recurrenceDays: [Int] = [],
        recurrenceEndDate: Date? = nil,
        recurrenceGroupId: String? = nil,
        reminderMinutesBefore: Int? = nil
    ) {
        self.title = title
        self.eventDate = eventDate
        self.endDate = endDate
        self.notes = notes
        self.eventTypeValue = eventType.rawValue
        self.createdByName = createdByName
        self.colorHex = colorHex
        self.isRecurring = isRecurring
        self.recurrenceDaysData = encodeJSON(recurrenceDays)
        self.recurrenceEndDate = recurrenceEndDate
        self.recurrenceGroupId = recurrenceGroupId
        self.reminderMinutesBefore = reminderMinutesBefore
    }
}

// MARK: - Calendar Event Extensions

extension CalendarEvent {
    var recurrenceDays: [Int] {
        get { decodeJSON([Int].self, from: recurrenceDaysData) ?? [] }
        set { recurrenceDaysData = encodeJSON(newValue) }
    }

    var eventType: EventType {
        get { EventType(rawValue: eventTypeValue) ?? .personal }
        set { eventTypeValue = newValue.rawValue }
    }
}

enum EventType: String, Codable, CaseIterable {
    case school, sports, family, personal
}

// MARK: - Goal

@Model
final class Goal {
    var title: String
    var createdByChildName: String
    var createdByParentName: String?
    var hasHabit: Bool
    var habitFrequencyValue: String?

    var completedDatesData: Data

    var shareCompletionToChat: Bool
    var createdDate: Date
    var pointValue: Int
    var totalPointsEarned: Int
    var statusValue: String
    var parentNote: String?
    var currentStreak: Int
    var longestStreak: Int
    var lastCompletedDate: Date?
    var targetDate: Date?
    var deletionRequested: Bool
    var deletionRequestedDate: Date?
    
    @Relationship(deleteRule: .cascade, inverse: \GoalMilestone.goal)
    var milestones: [GoalMilestone]

    init(title: String, createdByChildName: String) {
        self.title = title
        self.createdByChildName = createdByChildName
        self.createdByParentName = nil
        self.hasHabit = false
        self.habitFrequencyValue = nil
        self.completedDatesData = Data()
        self.shareCompletionToChat = false
        self.createdDate = Date()
        self.pointValue = 10
        self.totalPointsEarned = 0
        self.statusValue = GoalStatus.pending.rawValue
        self.parentNote = nil
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastCompletedDate = nil
        self.targetDate = nil
        self.deletionRequested = false
        self.deletionRequestedDate = nil
        self.milestones = []
    }
    
    convenience init(
        title: String,
        createdByChildName: String,
        createdByParentName: String?,
        hasHabit: Bool,
        habitFrequency: HabitFrequency?,
        shareCompletionToChat: Bool,
        pointValue: Int,
        targetDate: Date?
    ) {
        self.init(title: title, createdByChildName: createdByChildName)
        self.createdByParentName = createdByParentName
        self.hasHabit = hasHabit
        self.habitFrequencyValue = habitFrequency?.rawValue
        self.shareCompletionToChat = shareCompletionToChat
        self.pointValue = pointValue
        self.targetDate = targetDate
        
        // If created by parent, auto-approve
        if createdByParentName != nil {
            self.statusValue = GoalStatus.approved.rawValue
        }
    }
}

// MARK: - Goal Extensions (Computed Properties)

extension Goal {
    var completedDates: [Date] {
        get { decodeJSON([Date].self, from: completedDatesData) ?? [] }
        set { completedDatesData = encodeJSON(newValue) }
    }
    
    var creatorType: GoalCreatorType {
        if createdByParentName != nil {
            return .parent
        } else if status == .pending {
            return .childSuggested
        } else {
            return .child
        }
    }

    var habitFrequency: HabitFrequency? {
        get { habitFrequencyValue.flatMap { HabitFrequency(rawValue: $0) } }
        set { habitFrequencyValue = newValue?.rawValue }
    }

    var status: GoalStatus {
        get { GoalStatus(rawValue: statusValue) ?? .pending }
        set { statusValue = newValue.rawValue }
    }
}

// MARK: - Goal Milestone

@Model
final class GoalMilestone {
    var title: String
    var isCompleted: Bool
    var completedDate: Date?
    var order: Int

    var goal: Goal?

    init(title: String, order: Int) {
        self.title = title
        self.isCompleted = false
        self.completedDate = nil
        self.order = order
        self.goal = nil
    }
}

enum HabitFrequency: String, Codable, CaseIterable {
    case daily, weekly
}

enum GoalStatus: String, Codable, CaseIterable {
    case pending, approved, rejected, completed
}

enum GoalCreatorType: String, Codable, CaseIterable {
    case parent
    case child
    case childSuggested
}

