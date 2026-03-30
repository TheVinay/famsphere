import Foundation

extension Goal {

    /// Whether the goal has a completion entry for today (based on current calendar day).
    func isCompletedToday() -> Bool {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return completedDates.contains { cal.startOfDay(for: $0) == today }
    }

    /// Recalculate the current and longest streak based on `completedDates`.
    func recalculateStreak() {
        let cal = Calendar.current
        let sorted = completedDates.map { cal.startOfDay(for: $0) }.sorted()

        var longest = 0
        var current = 0
        var prev: Date?

        for day in sorted {
            if let p = prev,
               let diff = cal.dateComponents([.day], from: p, to: day).day,
               diff == 1 {
                current += 1
            } else {
                current = 1
            }
            longest = max(longest, current)
            prev = day
        }

        self.currentStreak = current
        self.longestStreak = longest
    }

    /// Mark the goal as completed for a specific day (default today).
    func markCompleted(on date: Date = Date()) {
        let cal = Calendar.current
        let day = cal.startOfDay(for: date)

        if !completedDates.contains(where: { cal.startOfDay(for: $0) == day }) {
            completedDates.append(date)
        }

        recalculateStreak()
        
        // Update points earned
        self.totalPointsEarned += self.pointValue
        self.lastCompletedDate = date
    }

    /// Completion rate as a percentage (0–100) over the last 30 days.
    var completionRate: Double {
        // Proportion of days with completions in the last 30 days (0.0 - 1.0)
        let cal = Calendar.current
        let now = Date()

        guard let start = cal.date(byAdding: .day, value: -30, to: now) else {
            return 0
        }

        let days = max(
            1,
            cal.dateComponents(
                [.day],
                from: cal.startOfDay(for: start),
                to: cal.startOfDay(for: now)
            ).day ?? 1
        )

        let count = completedDates.filter { $0 >= start }.count
        return Double(count) / Double(days)
    }
    
    /// Progress percentage for habit goals (0.0 to 1.0)
    var progressPercentage: Double {
        guard hasHabit else { return 0.0 }
        
        // Calculate based on time elapsed since creation
        let calendar = Calendar.current
        let now = Date()
        
        // Days since goal was created
        let daysSinceCreation = max(1, calendar.dateComponents([.day], from: createdDate, to: now).day ?? 1)
        
        // Expected completions based on frequency
        var expectedCompletions = 0
        if let frequency = habitFrequency {
            switch frequency {
            case .daily:
                expectedCompletions = daysSinceCreation
            case .weekly:
                expectedCompletions = daysSinceCreation / 7
            }
        }
        
        guard expectedCompletions > 0 else { return 0.0 }
        
        // Return actual completions / expected completions, capped at 1.0
        return min(1.0, Double(totalCompletions) / Double(expectedCompletions))
    }
}
