//
//  DashboardView.swift
//  FamSphere
//
//  Created by Vinays Mac on 1/5/26.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(AppSettings.self) private var appSettings
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Goal.createdDate, order: .reverse)
    private var allGoals: [Goal]
    
    @Query(sort: \FamilyMember.name)
    private var familyMembers: [FamilyMember]
    
    @Query(sort: \ChatMessage.timestamp, order: .reverse)
    private var allMessages: [ChatMessage]
    
    @State private var showingAddGoal = false
    @State private var showingApprovalQueue = false
    
    private var isParent: Bool {
        appSettings.currentUserRole == .parent
    }
    
    private var children: [FamilyMember] {
        familyMembers.filter { $0.role == .child }
    }
    
    private var isSingleChild: Bool {
        children.count == 1
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Welcome Header
                    headerView
                    
                    // Dashboard widgets will go here
                    familyOverviewWidget
                    
                    // Family Leaderboard vs Personal Progress Board (for parents)
                    if isParent {
                        if isSingleChild {
                            // Single child: Show personal progress board
                            singleChildProgressWidget
                        } else if !children.isEmpty {
                            // Multiple children: Show family leaderboard
                            familyLeaderboardWidget
                        }
                    }
                    
                    // Personal Progress (for children)
                    if !isParent {
                        personalProgressWidget
                    }
                    
                    // Recent Activity Feed
                    recentActivityWidget
                    
                    // Upcoming Deadlines
                    if !goalsWithDeadlines.isEmpty {
                        upcomingDeadlinesWidget
                    }
                    
                    // Weekly Statistics
                    weeklyStatsWidget
                    
                    // Quick Actions
                    quickActionsWidget
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView()
            }
            .sheet(isPresented: $showingApprovalQueue) {
                ApprovalQueueView(pendingGoals: allGoals.filter { $0.status == .pending })
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome back,")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(appSettings.currentUserName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("(\(isParent ? "Parent" : "Child"))")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            
            Text(isParent ? "Family Overview" : "Your Progress")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Family Overview Widget
    
    private var familyOverviewWidget: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "house.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                
                Text("Family Overview")
                    .font(.headline)
                
                Spacer()
            }
            
            // Quick stats grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                QuickStatCard(
                    icon: "person.2.fill",
                    value: "\(children.count)",
                    label: "Children",
                    color: .blue
                )
                
                QuickStatCard(
                    icon: "target",
                    value: "\(allGoals.count)",
                    label: "Total Goals",
                    color: .green
                )
                
                QuickStatCard(
                    icon: "star.fill",
                    value: "\(totalFamilyPoints)",
                    label: "Family Points",
                    color: .yellow
                )
                
                QuickStatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(totalCompletions)",
                    label: "Completions",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Computed Properties
    
    private var totalFamilyPoints: Int {
        allGoals.reduce(0) { (sum: Int, goal: Goal) in
            sum + goal.totalPointsEarned
        }
    }
    
    private var totalCompletions: Int {
        allGoals.reduce(0) { (sum: Int, goal: Goal) in
            sum + goal.totalCompletions
        }
    }
    
    private var leaderboardData: [(child: String, points: Int, goals: Int, bestStreak: Int)] {
        children.map { child in
            let childGoals = allGoals.filter { $0.createdByChildName == child.name }
            let points = childGoals.reduce(0) { (sum: Int, goal: Goal) in
                sum + goal.totalPointsEarned
            }
            let goalCount = childGoals.count
            let bestStreak = childGoals.map { $0.currentStreak }.max() ?? 0
            
            return (child: child.name, points: points, goals: goalCount, bestStreak: bestStreak)
        }
        .sorted { $0.points > $1.points }
    }
    
    private var myGoals: [Goal] {
        allGoals.filter { $0.createdByChildName == appSettings.currentUserName }
    }
    
    private var myPoints: Int {
        myGoals.reduce(0) { (sum: Int, goal: Goal) in
            sum + goal.totalPointsEarned
        }
    }
    
    private var recentActivities: [ActivityItem] {
        var activities: [ActivityItem] = []
        
        // Get recent completions from goals
        for goal in allGoals.prefix(20) {
            for date in goal.completedDates.sorted(by: >).prefix(5) {
                activities.append(ActivityItem(
                    type: .completion,
                    title: goal.title,
                    user: goal.createdByChildName,
                    timestamp: date,
                    points: goal.pointValue
                ))
            }
        }
        
        // Get recent chat messages about goals (achievements, approvals)
        let goalMessages = allMessages.filter { message in
            message.content.contains("approved") ||
            message.content.contains("streak") ||
            message.content.contains("completed")
        }.prefix(10)
        
        for message in goalMessages {
            let type: ActivityItem.ActivityType
            if message.content.contains("approved") {
                type = .approval
            } else if message.content.contains("streak") {
                type = .milestone
            } else {
                type = .completion
            }
            
            activities.append(ActivityItem(
                type: type,
                title: message.content,
                user: extractUserName(from: message.content),
                timestamp: message.timestamp,
                points: nil
            ))
        }
        
        // Sort by timestamp and take the 10 most recent
        return activities.sorted { $0.timestamp > $1.timestamp }.prefix(10).map { $0 }
    }
    
    private func extractUserName(from message: String) -> String {
        // Extract user name from messages like "✅ 'Goal' has been approved for UserName!"
        if let range = message.range(of: "for ") {
            let afterFor = message[range.upperBound...]
            if let endRange = afterFor.range(of: "!") {
                return String(afterFor[..<endRange.lowerBound])
            }
        }
        
        // Extract from completion messages like "🎉 UserName completed: Goal"
        if let range = message.range(of: "🎉 ") {
            let afterEmoji = message[range.upperBound...]
            if let endRange = afterEmoji.range(of: " completed") {
                return String(afterEmoji[..<endRange.lowerBound])
            } else if let endRange = afterEmoji.range(of: " reached") {
                return String(afterEmoji[..<endRange.lowerBound])
            }
        }
        
        return "Unknown"
    }
    
    private var goalsWithDeadlines: [Goal] {
        allGoals
            .filter { $0.targetDate != nil }
            .sorted { goal1, goal2 in
                guard let days1 = goal1.daysUntilDeadline,
                      let days2 = goal2.daysUntilDeadline else {
                    return false
                }
                return days1 < days2
            }
            .prefix(5)
            .map { $0 }
    }
    
    private var pendingApprovalCount: Int {
        allGoals.filter { $0.status == .pending }.count
    }
    
    private var weeklyCompletions: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        return allGoals.reduce(0) { (total: Int, goal: Goal) in
            let recentCompletions = goal.completedDates.filter { $0 >= weekAgo }.count
            return total + recentCompletions
        }
    }
    
    private var weeklyPoints: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        return allGoals.reduce(0) { (total: Int, goal: Goal) in
            let recentCompletions = goal.completedDates.filter { $0 >= weekAgo }.count
            return total + (recentCompletions * goal.pointValue)
        }
    }
    
    private var activeStreaks: Int {
        allGoals.filter { $0.currentStreak > 0 }.count
    }
    
    // MARK: - Weekly Statistics Widget
    
    private var weeklyStatsWidget: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.xaxis")
                    .font(.title2)
                    .foregroundStyle(.blue)
                
                Text("This Week")
                    .font(.headline)
                
                Spacer()
                
                Text("Last 7 Days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 12) {
                WeeklyStatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(weeklyCompletions)",
                    label: "Completions",
                    color: .green
                )
                
                WeeklyStatCard(
                    icon: "star.fill",
                    value: "\(weeklyPoints)",
                    label: "Points",
                    color: .yellow
                )
                
                WeeklyStatCard(
                    icon: "flame.fill",
                    value: "\(activeStreaks)",
                    label: "Streaks",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Quick Actions Widget
    
    private var quickActionsWidget: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "bolt.fill")
                    .font(.title2)
                    .foregroundStyle(.yellow)
                
                Text("Quick Actions")
                    .font(.headline)
                
                Spacer()
            }
            
            if isParent {
                // Parent actions
                VStack(spacing: 12) {
                    if pendingApprovalCount > 0 {
                        QuickActionButton(
                            icon: "clock.badge.exclamationmark",
                            title: "Review Approvals",
                            subtitle: "\(pendingApprovalCount) goal\(pendingApprovalCount == 1 ? "" : "s") pending",
                            color: .orange
                        ) {
                            showingApprovalQueue = true
                        }
                    }
                    
                    NavigationLink(destination: GoalsView()) {
                        QuickActionButtonContent(
                            icon: "target",
                            title: "View All Goals",
                            subtitle: "\(allGoals.count) total goals",
                            color: .blue
                        )
                    }
                    .buttonStyle(.plain)
                }
            } else {
                // Child actions
                VStack(spacing: 12) {
                    QuickActionButton(
                        icon: "plus.circle.fill",
                        title: "Add New Goal",
                        subtitle: "Create a new goal to track",
                        color: .green
                    ) {
                        showingAddGoal = true
                    }
                    
                    NavigationLink(destination: GoalsView()) {
                        QuickActionButtonContent(
                            icon: "target",
                            title: "View My Goals",
                            subtitle: "\(myGoals.count) active goals",
                            color: .blue
                        )
                    }
                    .buttonStyle(.plain)
                    
                    if let nextDeadline = goalsWithDeadlines.first, let days = nextDeadline.daysUntilDeadline {
                        NavigationLink(destination: GoalsView()) {
                            QuickActionButtonContent(
                                icon: "calendar.badge.clock",
                                title: "Next Deadline",
                                subtitle: "\(nextDeadline.title) - \(days)d",
                                color: days <= 2 ? .red : .orange
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Upcoming Deadlines Widget
    
    private var upcomingDeadlinesWidget: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundStyle(.orange)
                
                Text("Upcoming Deadlines")
                    .font(.headline)
                
                Spacer()
                
                if goalsWithDeadlines.count > 5 {
                    Text("+\(goalsWithDeadlines.count - 5)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            ForEach(goalsWithDeadlines) { goal in
                DeadlineRowView(goal: goal)
                
                if goal.id != goalsWithDeadlines.last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Recent Activity Widget
    
    private var recentActivityWidget: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .font(.title2)
                    .foregroundStyle(.purple)
                
                Text("Recent Activity")
                    .font(.headline)
                
                Spacer()
            }
            
            if recentActivities.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    
                    Text("No recent activity")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ForEach(recentActivities) { activity in
                    ActivityRowView(activity: activity)
                    
                    if activity.id != recentActivities.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Family Leaderboard Widget
    
    private var familyLeaderboardWidget: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.title2)
                    .foregroundStyle(.yellow)
                
                Text("Family Leaderboard")
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if leaderboardData.isEmpty {
                Text("No data yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(Array(leaderboardData.enumerated()), id: \.element.child) { index, data in
                    LeaderboardRow(
                        rank: index + 1,
                        childName: data.child,
                        points: data.points,
                        goalCount: data.goals,
                        bestStreak: data.bestStreak
                    )
                    
                    if index < leaderboardData.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Single Child Progress Widget (Parent View)
    
    private var singleChildProgressWidget: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2)
                    .foregroundStyle(.blue)
                
                Text("\(children.first?.name ?? "Your") Progress")
                    .font(.headline)
                
                Spacer()
            }
            
            if let child = children.first {
                let childGoals = allGoals.filter { $0.createdByChildName == child.name }
                let childPoints = childGoals.reduce(0) { $0 + $1.totalPointsEarned }
                let bestStreak = childGoals.map { $0.currentStreak }.max() ?? 0
                let longestStreak = childGoals.map { $0.longestStreak }.max() ?? 0
                
                // Stats Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatCardCompact(
                        icon: "star.fill",
                        value: "\(childPoints)",
                        label: "Total Points",
                        color: .yellow
                    )
                    
                    StatCardCompact(
                        icon: "flame.fill",
                        value: "\(bestStreak)",
                        label: "Current Streak",
                        color: .orange
                    )
                    
                    StatCardCompact(
                        icon: "trophy.fill",
                        value: "\(longestStreak)",
                        label: "Longest Streak",
                        color: .purple
                    )
                    
                    StatCardCompact(
                        icon: "target",
                        value: "\(childGoals.count)",
                        label: "Active Goals",
                        color: .green
                    )
                }
                
                // Best Week/Month Progress
                if let weekComparison = weeklyProgressComparison(for: child.name) {
                    Divider()
                        .padding(.vertical, 8)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: weekComparison.trend == .up ? "arrow.up.circle.fill" : weekComparison.trend == .down ? "arrow.down.circle.fill" : "minus.circle.fill")
                                .foregroundStyle(weekComparison.trend == .up ? .green : weekComparison.trend == .down ? .orange : .secondary)
                            
                            Text(weekComparison.message)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                    }
                }
                
                // Milestone Achievements
                if bestStreak >= 7 {
                    Divider()
                        .padding(.vertical, 8)
                    
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.yellow)
                        
                        Text(streakAchievementMessage(for: bestStreak))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Personal Progress Widget
    
    private var personalProgressWidget: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                
                Text("Your Progress")
                    .font(.headline)
                
                Spacer()
            }
            
            // Stats
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("\(myPoints)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.yellow)
                    
                    Text("Points")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 40)
                
                VStack(spacing: 4) {
                    Text("\(myGoals.filter { $0.status == .approved }.count)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                    
                    Text("Active Goals")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 40)
                
                VStack(spacing: 4) {
                    Text("\(myGoals.map { $0.currentStreak }.max() ?? 0)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.orange)
                    
                    Text("Best Streak")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            
            // Context-aware motivational messaging
            if isSingleChild {
                // Single child: Self-comparison messaging
                if let weekComparison = weeklyProgressComparison(for: appSettings.currentUserName) {
                    HStack {
                        Image(systemName: weekComparison.trend == .up ? "arrow.up.circle.fill" : weekComparison.trend == .down ? "arrow.down.circle.fill" : "minus.circle.fill")
                            .foregroundStyle(weekComparison.trend == .up ? .green : weekComparison.trend == .down ? .orange : .secondary)
                        
                        Text(weekComparison.message)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(weekComparison.trend == .up ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                // Achievement messaging for single child
                let bestStreak = myGoals.map { $0.currentStreak }.max() ?? 0
                if bestStreak >= 7 {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.yellow)
                        
                        Text(streakAchievementMessage(for: bestStreak))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            } else {
                // Multiple children: Family ranking
                let myRank = leaderboardData.firstIndex(where: { $0.child == appSettings.currentUserName }) ?? 0
                
                HStack {
                    Image(systemName: rankIcon(for: myRank + 1))
                        .foregroundStyle(rankColor(for: myRank + 1))
                    
                    Text("Ranked #\(myRank + 1) in family!")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(rankColor(for: myRank + 1).opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Helper Functions
    
    private enum ProgressTrend {
        case up, down, stable
    }
    
    private struct WeeklyComparison {
        let trend: ProgressTrend
        let message: String
    }
    
    private func weeklyProgressComparison(for childName: String) -> WeeklyComparison? {
        let calendar = Calendar.current
        let now = Date()
        
        // Get goals for this child
        let childGoals = allGoals.filter { $0.createdByChildName == childName }
        guard !childGoals.isEmpty else { return nil }
        
        // This week (last 7 days)
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let thisWeekPoints = childGoals.reduce(0) { (total: Int, goal: Goal) in
            let completions = goal.completedDates.filter { $0 >= weekAgo }.count
            return total + (completions * goal.pointValue)
        }
        
        // Previous week (8-14 days ago)
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: now) ?? now
        let lastWeekPoints = childGoals.reduce(0) { (total: Int, goal: Goal) in
            let completions = goal.completedDates.filter { $0 >= twoWeeksAgo && $0 < weekAgo }.count
            return total + (completions * goal.pointValue)
        }
        
        // Calculate trend
        if thisWeekPoints > lastWeekPoints {
            let increase = thisWeekPoints - lastWeekPoints
            return WeeklyComparison(
                trend: .up,
                message: increase > 0 ? "Up \(increase) points from last week!" : "Great progress this week!"
            )
        } else if thisWeekPoints < lastWeekPoints {
            return WeeklyComparison(
                trend: .down,
                message: "Keep pushing - you've got this!"
            )
        } else if thisWeekPoints > 0 {
            return WeeklyComparison(
                trend: .stable,
                message: "Steady progress - keep it up!"
            )
        }
        
        return nil
    }
    
    private func streakAchievementMessage(for streak: Int) -> String {
        switch streak {
        case 100...: return "Streak Champion! 100+ days! 🏆"
        case 50..<100: return "Incredible! \(streak)-day streak!"
        case 30..<50: return "Streak Master! \(streak) days!"
        case 14..<30: return "Two weeks strong! \(streak) days!"
        case 7..<14: return "One week streak! Keep going!"
        default: return "Building momentum!"
        }
    }
    
    private func rankIcon(for rank: Int) -> String {
        switch rank {
        case 1: return "trophy.fill"
        case 2: return "medal.fill"
        case 3: return "medal.fill"
        default: return "number.circle.fill"
        }
    }
    
    private func rankColor(for rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue
        }
    }
}

// MARK: - Quick Stat Card

struct QuickStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Stat Card Compact (for single-child mode)

struct StatCardCompact: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Leaderboard Row

struct LeaderboardRow: View {
    let rank: Int
    let childName: String
    let points: Int
    let goalCount: Int
    let bestStreak: Int
    
    private var rankEmoji: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)"
        }
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text(rankEmoji)
                .font(rank <= 3 ? .title2 : .headline)
                .frame(width: 40)
            
            // Child info
            VStack(alignment: .leading, spacing: 4) {
                Text(childName)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                HStack(spacing: 12) {
                    Label("\(goalCount)", systemImage: "target")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if bestStreak > 0 {
                        Label("\(bestStreak)", systemImage: "flame.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }
            
            Spacer()
            
            // Points
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
                
                Text("\(points)")
                    .font(.title3)
                    .fontWeight(.bold)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Activity Item

struct ActivityItem: Identifiable {
    let id = UUID()
    let type: ActivityType
    let title: String
    let user: String
    let timestamp: Date
    let points: Int?
    
    enum ActivityType {
        case completion
        case milestone
        case approval
        case rejection
        
        var icon: String {
            switch self {
            case .completion: return "checkmark.circle.fill"
            case .milestone: return "flame.fill"
            case .approval: return "checkmark.seal.fill"
            case .rejection: return "xmark.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .completion: return .green
            case .milestone: return .orange
            case .approval: return .blue
            case .rejection: return .red
            }
        }
    }
}

// MARK: - Activity Row View

struct ActivityRowView: View {
    let activity: ActivityItem
    
    private var timeAgo: String {
        let now = Date()
        let components = Calendar.current.dateComponents([.minute, .hour, .day], from: activity.timestamp, to: now)
        
        if let days = components.day, days > 0 {
            return "\(days)d ago"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)h ago"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m ago"
        } else {
            return "Just now"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: activity.type.icon)
                .font(.title3)
                .foregroundStyle(activity.type.color)
                .frame(width: 32)
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                if activity.type == .completion {
                    Text(activity.user)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("Completed: \(activity.title)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else {
                    Text(activity.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                Text(timeAgo)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            
            Spacer()
            
            // Points (if applicable)
            if let points = activity.points {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                    Text("+\(points)")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.yellow)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Deadline Row View

struct DeadlineRowView: View {
    let goal: Goal
    
    private var deadlineColor: Color {
        guard let daysRemaining = goal.daysUntilDeadline else { return .gray }
        
        if daysRemaining < 0 {
            return .red // Overdue
        } else if daysRemaining <= 2 {
            return .red // Urgent
        } else if daysRemaining <= 7 {
            return .orange // Soon
        } else {
            return .green // Plenty of time
        }
    }
    
    private var deadlineText: String {
        guard let daysRemaining = goal.daysUntilDeadline else { return "No deadline" }
        
        if daysRemaining < 0 {
            return "Overdue by \(abs(daysRemaining))d"
        } else if daysRemaining == 0 {
            return "Due today!"
        } else if daysRemaining == 1 {
            return "Due tomorrow"
        } else {
            return "In \(daysRemaining) days"
        }
    }
    
    private var deadlineIcon: String {
        guard let daysRemaining = goal.daysUntilDeadline else { return "calendar" }
        
        if daysRemaining < 0 {
            return "exclamationmark.triangle.fill"
        } else if daysRemaining <= 2 {
            return "alarm.fill"
        } else {
            return "calendar.badge.clock"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Urgency indicator
            Image(systemName: deadlineIcon)
                .font(.title3)
                .foregroundStyle(deadlineColor)
                .frame(width: 32)
            
            // Goal info
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(goal.createdByChildName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if let targetDate = goal.targetDate {
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(targetDate, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Countdown
            VStack(alignment: .trailing, spacing: 2) {
                Text(deadlineText)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(deadlineColor)
                
                if goal.status != .approved {
                    Text(goal.status.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Weekly Stat Card

struct WeeklyStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            QuickActionButtonContent(
                icon: icon,
                title: title,
                subtitle: subtitle,
                color: color
            )
        }
        .buttonStyle(.plain)
    }
}

struct QuickActionButtonContent: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    DashboardView()
        .environment(AppSettings())
        .modelContainer(for: [FamilyMember.self, ChatMessage.self, CalendarEvent.self, Goal.self])
}
