import Foundation

extension Goal {
    /// Number of days from today until the goal's target date.
    /// - Returns: Positive for days remaining, 0 for today, negative for overdue. Returns nil if no target date is set.
    var daysUntilDeadline: Int? {
        guard let targetDate = self.targetDate else { return nil }
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.startOfDay(for: targetDate)
        return calendar.dateComponents([.day], from: start, to: end).day
    }

    /// Total number of completion entries recorded for this goal.
    var totalCompletions: Int {
        // Assumes Goal has a `completedDates: [Date]` collection.
        // If this property is absent or named differently, update accordingly.
        return self.completedDates.count
    }
}
