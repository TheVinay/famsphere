//
//  GoalsView.swift
//  FamSphere
//
//  Created by Vinays Mac on 12/30/25.
//

import SwiftUI
import SwiftData

struct GoalsView: View {
    @Environment(AppSettings.self) private var appSettings
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Goal.createdDate, order: .reverse)
    private var allGoals: [Goal]
    
    @State private var showingAddGoal = false
    @State private var showingPointsSummary = false
    @State private var showingApprovalQueue = false
    
    private var myGoals: [Goal] {
        allGoals.filter { $0.createdByChildName == appSettings.currentUserName }
    }
    
    private var myTotalPoints: Int {
        myGoals.reduce(0) { $0 + $1.totalPointsEarned }
    }
    
    private var approvedGoals: [Goal] {
        allGoals.filter { $0.status == .approved }
    }
    
    private var pendingGoalsCount: Int {
        allGoals.filter { $0.status == .pending }.count
    }
    
    private var isChild: Bool {
        appSettings.currentUserRole == .child
    }
    
    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle(isChild ? "My Goals" : "Family Goals")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if isChild {
                        ToolbarItem(placement: .topBarLeading) {
                            pointsBadgeButton
                        }
                        
                        ToolbarItem(placement: .primaryAction) {
                            addButton
                        }
                    } else {
                        // Parent view - add button AND approval queue
                        ToolbarItem(placement: .primaryAction) {
                            addButton
                        }
                        
                        if pendingGoalsCount > 0 {
                            ToolbarItem(placement: .topBarTrailing) {
                                approvalQueueButton
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingAddGoal) {
                    AddGoalView()
                        .onAppear {
                            print("🔵 Presenting AddGoalView sheet")
                        }
                }
                .sheet(isPresented: $showingPointsSummary) {
                    PointsSummaryView(goals: myGoals, totalPoints: myTotalPoints)
                }
                .sheet(isPresented: $showingApprovalQueue) {
                    ApprovalQueueView(pendingGoals: allGoals.filter { $0.status == .pending })
                }
                .onAppear {
                    print("🔵 GoalsView appeared - isChild: \(isChild), user role: \(appSettings.currentUserRole)")
                }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if allGoals.isEmpty {
            emptyStateView
        } else {
            goalsList
        }
    }
    
    private var addButton: some View {
        Button {
            print("🔵 Add Goal button tapped (Child role)")
            showingAddGoal = true
        } label: {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundStyle(.blue)
        }
    }
    
    private var pointsBadgeButton: some View {
        Button {
            showingPointsSummary = true
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption)
                Text("\(myTotalPoints)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.yellow.gradient)
            )
            .foregroundStyle(.white)
        }
    }
    
    private var approvalQueueButton: some View {
        Button {
            showingApprovalQueue = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "clock.badge.exclamationmark")
                    .font(.body)
                Text("\(pendingGoalsCount)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.orange.gradient)
            )
            .foregroundStyle(.white)
        }
    }
    
    private var goalsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Points summary card for children
                if isChild && !myGoals.isEmpty {
                    pointsSummaryCard
                }
                
                if isChild {
                    childGoalsView
                } else {
                    parentGoalsView
                }
            }
            .padding()
        }
    }
    
    private var pointsSummaryCard: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "star.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.yellow)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total Points")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(myTotalPoints)")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                Button {
                    showingPointsSummary = true
                } label: {
                    Text("Details")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.yellow.opacity(0.2), Color.orange.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var childGoalsView: some View {
        VStack(spacing: 16) {
            // Helpful tip if child has approved goals but hasn't completed any yet
            if myGoals.contains(where: { $0.status == .approved && $0.totalCompletions == 0 }) {
                HStack(spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .font(.title2)
                        .foregroundStyle(.yellow)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("How to Mark Goals Complete")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text("Tap the blue \"Mark Complete\" button on any goal to track your progress and earn points!")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.yellow.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            ForEach(myGoals) { goal in
                GoalCardView(goal: goal, canEdit: true)
            }
        }
    }
    
    private var parentGoalsView: some View {
        ForEach(groupedGoals, id: \.childName) { group in
            GoalGroupView(group: group)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text(isChild ? "Create Your First Goal" : "No Goals Yet")
                .font(.title2)
                .fontWeight(.medium)
            
            Text(isChild ? "Set goals to track your progress" : "Goals will appear here when family members create them")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            if isChild {
                Button {
                    showingAddGoal = true
                } label: {
                    Text("Add Goal")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var groupedGoals: [(childName: String, goals: [Goal])] {
        let grouped = Dictionary(grouping: allGoals, by: { $0.createdByChildName })
        return grouped.map { (childName: $0.key, goals: $0.value) }
            .sorted { $0.childName < $1.childName }
    }
}

// MARK: - Goal Group View (for Parents)

struct GoalGroupView: View {
    let group: (childName: String, goals: [Goal])
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(group.childName)'s Goals")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            ForEach(group.goals) { goal in
                GoalCardView(goal: goal, canEdit: false)
            }
        }
    }
}

// MARK: - Goal Card View

struct GoalCardView: View {
    let goal: Goal
    let canEdit: Bool
    
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    
    @State private var showingDeleteAlert = false
    @State private var showingStreakCelebration = false
    @State private var celebrationMessage = ""
    @State private var showingApprovalSheet = false
    @State private var showingStatistics = false
    @State private var showingEditSheet = false
    
    private var isParent: Bool {
        appSettings.currentUserRole == .parent
    }
    
    private var alertTitle: String {
        if isParent && goal.deletionRequested {
            return "Approve Deletion Request"
        } else if canEdit {
            return "Request Goal Deletion"
        } else {
            return "Delete Goal"
        }
    }
    
    private var alertButtonText: String {
        if isParent && goal.deletionRequested {
            return "Approve"
        } else if canEdit {
            return "Request Deletion"
        } else {
            return "Delete"
        }
    }
    
    private var alertMessage: String {
        if isParent && goal.deletionRequested {
            return "\(goal.createdByChildName) has requested to delete this goal. Approve deletion?"
        } else if canEdit {
            return "Your parent will be notified to approve this deletion request."
        } else {
            return "Are you sure you want to delete this goal? This cannot be undone."
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Deletion Request Badge (if child requested deletion)
            if goal.deletionRequested {
                HStack {
                    Image(systemName: "trash.circle")
                        .font(.caption)
                    Text("Deletion Requested")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.2))
                .foregroundStyle(.red)
                .clipShape(Capsule())
            }
            
            // Status Badge (if pending or rejected)
            if goal.status != .approved {
                HStack {
                    Image(systemName: goal.status.icon)
                        .font(.caption)
                    Text(goal.status.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(goal.status.color).opacity(0.2))
                .foregroundStyle(Color(goal.status.color))
                .clipShape(Capsule())
            }
            
            // Creator Badge
            HStack(spacing: 4) {
                Image(systemName: goal.creatorType.icon)
                    .font(.caption2)
                Text(goal.creatorType.badge)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(goal.creatorType.color).opacity(0.15))
            .foregroundStyle(Color(goal.creatorType.color))
            .clipShape(Capsule())
            
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.headline)
                    
                    HStack(spacing: 8) {
                        if goal.hasHabit, let frequency = goal.habitFrequency {
                            HStack(spacing: 4) {
                                Image(systemName: "repeat")
                                    .font(.caption)
                                Text(frequency.rawValue)
                                    .font(.caption)
                            }
                            .foregroundStyle(.secondary)
                        }
                        
                        // Streak badge
                        if goal.hasHabit && goal.currentStreak > 0 {
                            HStack(spacing: 3) {
                                Image(systemName: "flame.fill")
                                    .font(.caption2)
                                Text("\(goal.currentStreak)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.orange.opacity(0.2))
                            .foregroundStyle(.orange)
                            .clipShape(Capsule())
                        }
                        
                        // Points badge
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                            Text("\(goal.pointValue) pts")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.yellow.opacity(0.2))
                        .foregroundStyle(.orange)
                        .clipShape(Capsule())
                        
                        // Deadline badge
                        if let daysRemaining = goal.daysUntilDeadline {
                            HStack(spacing: 3) {
                                Image(systemName: "calendar.badge.clock")
                                    .font(.caption2)
                                Text("\(daysRemaining)d")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(deadlineColor(for: daysRemaining).opacity(0.2))
                            .foregroundStyle(deadlineColor(for: daysRemaining))
                            .clipShape(Capsule())
                        }
                    }
                }
                
                Spacer()
                
                // Menu button for actions
                Menu {
                    // Statistics option (for everyone)
                    if goal.totalCompletions > 0 {
                        Button {
                            showingStatistics = true
                        } label: {
                            Label("View Statistics", systemImage: "chart.bar.fill")
                        }
                    }
                    
                    // Edit option for parents
                    if isParent {
                        Button {
                            showingEditSheet = true
                        } label: {
                            Label("Edit Goal", systemImage: "pencil")
                        }
                    }
                    
                    // Deletion request handling
                    if isParent && goal.deletionRequested {
                        // Parent can approve deletion request
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Approve Deletion", systemImage: "checkmark.circle")
                        }
                        
                        Button {
                            denyDeletionRequest()
                        } label: {
                            Label("Deny Deletion", systemImage: "xmark.circle")
                        }
                    } else if canEdit && !goal.deletionRequested {
                        // Child can request deletion (if not already requested)
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Request Deletion", systemImage: "trash")
                        }
                    } else if isParent && !goal.deletionRequested {
                        // Parent can delete directly (if no pending request)
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete Goal", systemImage: "trash")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                
                // Approval button for pending goals
                if isParent && goal.status == .pending && !canEdit {
                    Button {
                        showingApprovalSheet = true
                    } label: {
                        Image(systemName: "checkmark.seal")
                            .font(.title3)
                            .foregroundStyle(.orange)
                    }
                }
            }
            
            // Deadline info banner (if deadline exists)
            if let targetDate = goal.targetDate, let daysRemaining = goal.daysUntilDeadline {
                HStack(spacing: 6) {
                    Image(systemName: daysRemaining < 0 ? "exclamationmark.triangle.fill" : "calendar.badge.clock")
                        .font(.caption)
                    
                    if daysRemaining < 0 {
                        Text("Overdue by \(abs(daysRemaining)) days")
                            .font(.caption)
                            .fontWeight(.medium)
                    } else if daysRemaining == 0 {
                        Text("Due today!")
                            .font(.caption)
                            .fontWeight(.medium)
                    } else if daysRemaining == 1 {
                        Text("Due tomorrow")
                            .font(.caption)
                            .fontWeight(.medium)
                    } else {
                        Text("Due \(targetDate, style: .date)")
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    if daysRemaining >= 0 {
                        Text("\(daysRemaining) day\(daysRemaining == 1 ? "" : "s") left")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(deadlineColor(for: daysRemaining).opacity(0.1))
                .foregroundStyle(deadlineColor(for: daysRemaining))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Parent note (if rejected)
            if goal.status == .rejected, let note = goal.parentNote {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                        .font(.caption)
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Progress Bar (if habit)
            if goal.hasHabit {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // Background
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(uiColor: .systemGray5))
                                    
                                    // Progress
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(
                                            LinearGradient(
                                                colors: [.green, .blue],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geometry.size.width * goal.progressPercentage)
                                }
                            }
                            .frame(height: 8)
                            
                            HStack {
                                Text("\(Int(goal.progressPercentage * 100))% completed")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                if goal.longestStreak > 0 {
                                    Spacer()
                                    Text("Best: \(goal.longestStreak) 🔥")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            
            // Check-in Button (if habit and editable)
            if goal.hasHabit && canEdit && goal.status == .approved {
                VStack(spacing: 8) {
                    Button(action: {
                        toggleCompletion()
                    }) {
                        HStack {
                            Image(systemName: goal.isCompletedToday() ? "checkmark.circle.fill" : "circle")
                                .font(.title3)
                            
                            Text(goal.isCompletedToday() ? "Completed Today" : "Mark Complete")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                        }
                        .padding()
                        .background(goal.isCompletedToday() ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                        .foregroundStyle(goal.isCompletedToday() ? .green : .blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    
                    // View Statistics button
                    if goal.totalCompletions > 0 {
                        Button {
                            showingStatistics = true
                        } label: {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .font(.caption)
                                Text("View Statistics")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundStyle(.purple)
                        }
                    }
                }
            } else if goal.status == .pending && canEdit {
                // Pending state message for child
                HStack {
                    Image(systemName: "clock")
                        .font(.subheadline)
                    Text("Waiting for parent approval")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange.opacity(0.1))
                .foregroundStyle(.orange)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else if goal.status == .rejected && canEdit {
                // Rejected state message for child
                HStack {
                    Image(systemName: "xmark.circle")
                        .font(.subheadline)
                    Text("Not approved - tap to edit")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .foregroundStyle(.red)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .alert(alertTitle, isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button(alertButtonText, role: .destructive) {
                if canEdit && !goal.deletionRequested {
                    // Child requests deletion
                    requestDeletion()
                } else {
                    // Parent approves deletion or deletes directly
                    modelContext.delete(goal)
                    
                    // Send confirmation message if it was a requested deletion
                    if goal.deletionRequested {
                        let message = ChatMessage(
                            content: "✅ \(appSettings.currentUserName) approved the deletion of '\(goal.title)'",
                            authorName: "FamSphere",
                            isImportant: false
                        )
                        modelContext.insert(message)
                    }
                }
            }
        } message: {
            Text(alertMessage)
        }
        .alert("Streak Milestone! 🔥", isPresented: $showingStreakCelebration) {
            Button("Awesome!", role: .cancel) {}
        } message: {
            Text(celebrationMessage)
        }
        .sheet(isPresented: $showingApprovalSheet) {
            GoalApprovalSheet(goal: goal)
        }
        .sheet(isPresented: $showingStatistics) {
            GoalStatisticsView(goal: goal)
        }
        .sheet(isPresented: $showingEditSheet) {
            EditGoalView(goal: goal)
        }
    }
    
    private func toggleCompletion() {
        if goal.isCompletedToday() {
            // Remove today's completion
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            goal.completedDates.removeAll { calendar.isDate($0, inSameDayAs: today) }
            
            // Recalculate streak after removal
            goal.recalculateStreak()
        } else {
            // Store previous streak to check for milestones
            let previousStreak = goal.currentStreak
            
            // Mark complete
            goal.markCompleted()
            
            // Check for streak milestones
            checkStreakMilestone(previousStreak: previousStreak, newStreak: goal.currentStreak)
            
            // Share to chat if enabled
            if goal.shareCompletionToChat {
                var messageContent = "🎉 \(appSettings.currentUserName) completed: \(goal.title)"
                
                // Add streak info to message if there's an active streak
                if goal.currentStreak > 1 {
                    messageContent += " (🔥 \(goal.currentStreak) day streak!)"
                }
                
                let message = ChatMessage(
                    content: messageContent,
                    authorName: "FamSphere",
                    isImportant: false
                )
                modelContext.insert(message)
            }
        }
    }
    
    private func checkStreakMilestone(previousStreak: Int, newStreak: Int) {
        let milestones = [3, 7, 14, 30, 50, 100]
        
        // Check if we just crossed a milestone
        for milestone in milestones {
            if previousStreak < milestone && newStreak >= milestone {
                celebrationMessage = "You've reached a \(milestone)-day streak on '\(goal.title)'! Keep it up! 🔥🎉"
                showingStreakCelebration = true
                
                // Also share milestone to chat
                let message = ChatMessage(
                    content: "🔥 \(goal.createdByChildName) reached a \(milestone)-day streak on '\(goal.title)'! Amazing!",
                    authorName: "FamSphere",
                    isImportant: true
                )
                modelContext.insert(message)
                
                break // Only show one milestone at a time
            }
        }
    }
    
    private func requestDeletion() {
        goal.deletionRequested = true
        goal.deletionRequestedDate = Date()
        
        // Notify parent via chat
        let message = ChatMessage(
            content: "⚠️ \(goal.createdByChildName) has requested to delete the goal: '\(goal.title)'. Please review and approve.",
            authorName: "FamSphere",
            isImportant: true
        )
        modelContext.insert(message)
    }
    
    private func denyDeletionRequest() {
        goal.deletionRequested = false
        goal.deletionRequestedDate = nil
        
        // Notify child via chat
        let message = ChatMessage(
            content: "ℹ️ The deletion request for '\(goal.title)' was denied by \(appSettings.currentUserName).",
            authorName: "FamSphere",
            isImportant: false
        )
        modelContext.insert(message)
    }
    
    private func deadlineColor(for daysRemaining: Int) -> Color {
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
}

// MARK: - Add Goal View

struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    @Query(sort: \FamilyMember.name) private var familyMembers: [FamilyMember]
    
    @State private var title = ""
    @State private var hasHabit = false
    @State private var habitFrequency: HabitFrequency = .daily
    @State private var shareCompletionToChat = false
    @State private var pointValue: Int = 10
    @State private var hasDeadline = false
    @State private var targetDate = Date().addingTimeInterval(7 * 24 * 60 * 60)
    @State private var selectedChildName = ""
    
    private var isParent: Bool {
        appSettings.currentUserRole == .parent
    }
    
    private var children: [FamilyMember] {
        familyMembers.filter { $0.role == .child }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Goal Title", text: $title)
                }
                
                // Parent can assign goal to a child
                if isParent && !children.isEmpty {
                    Section {
                        Picker("Assign To", selection: $selectedChildName) {
                            ForEach(children) { child in
                                Text(child.name).tag(child.name)
                            }
                        }
                    } header: {
                        Text("Assign Goal")
                    } footer: {
                        Text("This goal will be auto-approved and assigned to \(selectedChildName.isEmpty ? "the selected child" : selectedChildName)")
                    }
                }
                
                Section {
                    Toggle("Track as Habit", isOn: $hasHabit)
                    
                    if hasHabit {
                        Picker("Frequency", selection: $habitFrequency) {
                            ForEach(HabitFrequency.allCases, id: \.self) { frequency in
                                Text(frequency.rawValue).tag(frequency)
                            }
                        }
                        
                        Toggle("Share completions to chat", isOn: $shareCompletionToChat)
                    }
                } header: {
                    Text("Habit Tracking")
                } footer: {
                    Text("Habits help track progress over time with simple checkmarks")
                }
                
                Section {
                    Stepper("Point Value: \(pointValue)", value: $pointValue, in: 1...100, step: 5)
                    
                    Text("Earn \(pointValue) points each time this goal is completed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Rewards")
                }
                
                Section {
                    Toggle("Set Target Date", isOn: $hasDeadline)
                    
                    if hasDeadline {
                        DatePicker("Target Date", selection: $targetDate, in: Date()..., displayedComponents: .date)
                        
                        if let days = Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day {
                            Text("\(days) days from now")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Deadline")
                } footer: {
                    Text("Set a target date to stay motivated and track progress")
                }
            }
            .navigationTitle(isParent ? "Assign Goal" : "New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addGoal()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || (isParent && children.isEmpty))
                }
            }
            .onAppear {
                // Set initial child selection if parent and no child is selected yet
                if isParent && !children.isEmpty && selectedChildName.isEmpty {
                    selectedChildName = children[0].name
                    print("🔵 Auto-selected first child: \(selectedChildName)")
                }
            }
        }
    }
    
    private func addGoal() {
        let goal = Goal(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            createdByChildName: isParent ? selectedChildName : appSettings.currentUserName,
            createdByParentName: isParent ? appSettings.currentUserName : nil,
            hasHabit: hasHabit,
            habitFrequency: hasHabit ? habitFrequency : nil,
            shareCompletionToChat: shareCompletionToChat,
            pointValue: pointValue,
            targetDate: hasDeadline ? targetDate : nil
        )
        
        modelContext.insert(goal)
        
        print("✅ Goal created by \(appSettings.currentUserRole): '\(goal.title)' for \(goal.createdByChildName)")
        if isParent {
            print("   Auto-approved parent goal")
        }
        
        dismiss()
    }
}

// MARK: - Points Summary View

struct PointsSummaryView: View {
    let goals: [Goal]
    let totalPoints: Int
    
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var appSettings
    @Query(sort: \FamilyMember.name) private var familyMembers: [FamilyMember]
    @State private var showingStreakDetails = false
    
    private var children: [FamilyMember] {
        familyMembers.filter { $0.role == .child }
    }
    
    private var isSingleChild: Bool {
        children.count == 1
    }
    
    private var topGoals: [Goal] {
        goals.sorted { $0.totalPointsEarned > $1.totalPointsEarned }.prefix(5).map { $0 }
    }
    
    private var topStreaks: [Goal] {
        goals.filter { $0.hasHabit && $0.currentStreak > 0 }
            .sorted { $0.currentStreak > $1.currentStreak }
            .prefix(3)
            .map { $0 }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Total Points Header
                    VStack(spacing: 8) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("\(totalPoints)")
                            .font(.system(size: 48, weight: .bold))
                        
                        Text("Total Points Earned")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(
                            icon: "trophy.fill",
                            value: "\(goals.count)",
                            label: "Active Goals",
                            color: .blue
                        )
                        
                        StatCard(
                            icon: "checkmark.circle.fill",
                            value: "\(goals.reduce(0) { $0 + $1.totalCompletions })",
                            label: "Total Completions",
                            color: .green
                        )
                        
                        Button {
                            showingStreakDetails = true
                        } label: {
                            StatCard(
                                icon: "flame.fill",
                                value: "\(goals.map { $0.currentStreak }.max() ?? 0)",
                                label: isSingleChild ? "Current Best" : "Best Streak",
                                color: .orange
                            )
                        }
                        .buttonStyle(.plain)
                        
                        StatCard(
                            icon: "chart.line.uptrend.xyaxis",
                            value: String(format: "%.0f%%", avgCompletionRate * 100),
                            label: "Avg Completion",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                    
                    // Personal Best / Progress Message (for single child)
                    if isSingleChild {
                        personalBestMessage
                    }
                    
                    // Top Goals
                    if !topGoals.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(isSingleChild ? "Your Best Goals" : "Top Goals")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(Array(topGoals.enumerated()), id: \.element.id) { index, goal in
                                HStack {
                                    if !isSingleChild {
                                        Text("#\(index + 1)")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.secondary)
                                            .frame(width: 40)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(goal.title)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        Text("\(goal.totalCompletions) completions")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 3) {
                                        Image(systemName: "star.fill")
                                            .font(.caption)
                                        Text("\(goal.totalPointsEarned)")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundStyle(.orange)
                                }
                                .padding()
                                .background(Color(uiColor: .secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Points Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingStreakDetails) {
                StreakDetailsView(goals: goals, topStreaks: topStreaks)
            }
        }
    }
    
    private var avgCompletionRate: Double {
        guard !goals.isEmpty else { return 0 }
        let total = goals.reduce(0.0) { $0 + $1.completionRate }
        return total / Double(goals.count)
    }
    
    @ViewBuilder
    private var personalBestMessage: some View {
        let bestStreak = goals.map { $0.currentStreak }.max() ?? 0
        
        if bestStreak > 0 {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: bestStreak >= 30 ? "trophy.fill" : bestStreak >= 7 ? "star.fill" : "flame.fill")
                        .foregroundStyle(bestStreak >= 30 ? .yellow : bestStreak >= 7 ? .orange : .blue)
                    
                    Text(personalBestText(for: bestStreak))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    (bestStreak >= 30 ? Color.yellow : bestStreak >= 7 ? Color.orange : Color.blue).opacity(0.1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
        }
    }
    
    private func personalBestText(for streak: Int) -> String {
        switch streak {
        case 100...: return "Streak Legend! Over 100 days! 🏆"
        case 50..<100: return "Incredible dedication! \(streak)-day streak!"
        case 30..<50: return "You're on fire! \(streak) days!"
        case 14..<30: return "Amazing progress! \(streak) days!"
        case 7..<14: return "One week strong! Keep it up!"
        case 3..<7: return "Great start! Building momentum!"
        default: return "You've got this! Keep going!"
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
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
                .font(.title2)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Streak Details View

struct StreakDetailsView: View {
    let goals: [Goal]
    let topStreaks: [Goal]
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Streak Header
                    VStack(spacing: 8) {
                        Image(systemName: "flame.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("\(goals.map { $0.currentStreak }.max() ?? 0)")
                            .font(.system(size: 48, weight: .bold))
                        
                        Text("Best Current Streak")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Streak Stats
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(
                            icon: "flame.fill",
                            value: "\(goals.map { $0.longestStreak }.max() ?? 0)",
                            label: "Longest Ever",
                            color: .red
                        )
                        
                        StatCard(
                            icon: "chart.line.uptrend.xyaxis",
                            value: "\(goals.filter { $0.currentStreak > 0 }.count)",
                            label: "Active Streaks",
                            color: .orange
                        )
                    }
                    .padding(.horizontal)
                    
                    // Milestone Progress
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Next Milestones")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach([3, 7, 14, 30, 50, 100], id: \.self) { milestone in
                            MilestoneProgressCard(
                                milestone: milestone,
                                currentStreak: goals.map { $0.currentStreak }.max() ?? 0
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Top Streaks
                    if !topStreaks.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Active Streaks")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(Array(topStreaks.enumerated()), id: \.element.id) { index, goal in
                                HStack {
                                    Text(["🥇", "🥈", "🥉"][index])
                                        .font(.title2)
                                        .frame(width: 40)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(goal.title)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        Text("Longest: \(goal.longestStreak) days")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 3) {
                                        Image(systemName: "flame.fill")
                                            .font(.caption)
                                        Text("\(goal.currentStreak)")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                    }
                                    .foregroundStyle(.orange)
                                }
                                .padding()
                                .background(Color(uiColor: .secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Streaks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Milestone Progress Card

struct MilestoneProgressCard: View {
    let milestone: Int
    let currentStreak: Int
    
    private var isCompleted: Bool {
        currentStreak >= milestone
    }
    
    private var progress: Double {
        guard !isCompleted else { return 1.0 }
        return Double(currentStreak) / Double(milestone)
    }
    
    var body: some View {
        HStack {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(isCompleted ? .green : .secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(milestone) Day Streak")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if !isCompleted {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(uiColor: .systemGray5))
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.orange.gradient)
                                .frame(width: geometry.size.width * progress)
                        }
                    }
                    .frame(height: 4)
                    
                    Text("\(milestone - currentStreak) more days to go")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if isCompleted {
                Text("🔥")
                    .font(.title2)
            }
        }
        .padding()
        .background(
            isCompleted ? 
                Color.orange.opacity(0.1) : 
                Color(uiColor: .secondarySystemGroupedBackground)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Approval Queue View

struct ApprovalQueueView: View {
    let pendingGoals: [Goal]
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            if pendingGoals.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 60))
                        .foregroundStyle(.green)
                    
                    Text("All Caught Up!")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text("No goals waiting for approval")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(pendingGoals) { goal in
                            ApprovalGoalCard(goal: goal)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Pending Approvals")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Approval Goal Card

struct ApprovalGoalCard: View {
    let goal: Goal
    
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    @State private var showingApprovalSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.headline)
                    
                    Text("by \(goal.createdByChildName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                    Text("\(goal.pointValue) pts")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.yellow.opacity(0.2))
                .foregroundStyle(.orange)
                .clipShape(Capsule())
            }
            
            if goal.hasHabit, let frequency = goal.habitFrequency {
                HStack(spacing: 4) {
                    Image(systemName: "repeat")
                        .font(.caption)
                    Text("\(frequency.rawValue) habit")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
            
            if let targetDate = goal.targetDate, let daysRemaining = goal.daysUntilDeadline {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text("Due \(targetDate, style: .date) (\(daysRemaining)d)")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 12) {
                Button {
                    approveGoal()
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Approve")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.green.opacity(0.2))
                    .foregroundStyle(.green)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                
                Button {
                    showingApprovalSheet = true
                } label: {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        Text("Reject")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.red.opacity(0.2))
                    .foregroundStyle(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .sheet(isPresented: $showingApprovalSheet) {
            GoalApprovalSheet(goal: goal)
        }
    }
    
    private func approveGoal() {
        goal.status = .approved
        
        // Send notification to chat
        let message = ChatMessage(
            content: "✅ '\(goal.title)' has been approved for \(goal.createdByChildName) by \(appSettings.currentUserName)!",
            authorName: "FamSphere",
            isImportant: true
        )
        modelContext.insert(message)
    }
}

// MARK: - Goal Approval Sheet

struct GoalApprovalSheet: View {
    let goal: Goal
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    @State private var action: ApprovalAction = .approve
    @State private var parentNote = ""
    @State private var adjustedPoints: Int
    
    init(goal: Goal) {
        self.goal = goal
        _adjustedPoints = State(initialValue: goal.pointValue)
    }
    
    enum ApprovalAction: String, CaseIterable {
        case approve = "Approve"
        case reject = "Reject"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(goal.title)
                        .font(.headline)
                    
                    HStack {
                        Text("Created by:")
                            .foregroundStyle(.secondary)
                        Text(goal.createdByChildName)
                    }
                    
                    if goal.hasHabit, let frequency = goal.habitFrequency {
                        HStack {
                            Text("Frequency:")
                                .foregroundStyle(.secondary)
                            Text(frequency.rawValue)
                        }
                    }
                    
                    if let targetDate = goal.targetDate {
                        HStack {
                            Text("Target Date:")
                                .foregroundStyle(.secondary)
                            Text(targetDate, style: .date)
                        }
                        
                        if let daysRemaining = goal.daysUntilDeadline {
                            HStack {
                                Text("Days Remaining:")
                                    .foregroundStyle(.secondary)
                                Text("\(daysRemaining)")
                                    .foregroundStyle(daysRemaining < 7 ? .orange : .primary)
                            }
                        }
                    }
                }
                
                Section {
                    Picker("Decision", selection: $action) {
                        ForEach(ApprovalAction.allCases, id: \.self) { action in
                            Text(action.rawValue).tag(action)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                if action == .approve {
                    Section {
                        Stepper("Points: \(adjustedPoints)", value: $adjustedPoints, in: 1...100, step: 5)
                        
                        if adjustedPoints != goal.pointValue {
                            HStack(spacing: 4) {
                                Image(systemName: "info.circle")
                                    .font(.caption)
                                Text("Child suggested: \(goal.pointValue) points")
                                    .font(.caption)
                            }
                            .foregroundStyle(.secondary)
                        }
                    } header: {
                        Text("Reward Points")
                    } footer: {
                        Text("You can adjust the point value before approving")
                    }
                }
                
                if action == .reject {
                    Section {
                        TextField("Reason for rejection", text: $parentNote, axis: .vertical)
                            .lineLimit(3...6)
                    } header: {
                        Text("Note to Child")
                    } footer: {
                        Text("Help them understand why this goal wasn't approved")
                    }
                }
            }
            .navigationTitle("Review Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(action == .approve ? "Approve" : "Reject") {
                        submitDecision()
                    }
                    .disabled(action == .reject && parentNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func submitDecision() {
        if action == .approve {
            goal.status = .approved
            goal.pointValue = adjustedPoints  // Apply adjusted points
            goal.parentNote = nil
            
            let pointsMessage = adjustedPoints != goal.pointValue ? " (adjusted to \(adjustedPoints) points)" : ""
            
            let message = ChatMessage(
                content: "✅ '\(goal.title)' has been approved for \(goal.createdByChildName) by \(appSettings.currentUserName)\(pointsMessage)!",
                authorName: "FamSphere",
                isImportant: true
            )
            modelContext.insert(message)
            
            print("✅ Goal approved by \(appSettings.currentUserName) with \(adjustedPoints) points (original: \(goal.pointValue))")
        } else {
            goal.status = .rejected
            goal.parentNote = parentNote.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let message = ChatMessage(
                content: "⚠️ '\(goal.title)' needs revision. Check your goals for feedback.",
                authorName: "FamSphere",
                isImportant: true
            )
            modelContext.insert(message)
        }
        
        dismiss()
    }
}

// MARK: - Goal Statistics View

struct GoalStatisticsView: View {
    let goal: Goal
    
    @Environment(\.dismiss) private var dismiss
    
    private var completionsByWeekday: [Int: Int] {
        let calendar = Calendar.current
        var counts: [Int: Int] = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0]
        
        for date in goal.completedDates {
            let weekday = calendar.component(.weekday, from: date)
            counts[weekday, default: 0] += 1
        }
        
        return counts
    }
    
    private var bestWeekday: String {
        let calendar = Calendar.current
        let maxCount = completionsByWeekday.values.max() ?? 0
        guard maxCount > 0 else { return "N/A" }
        
        let bestDay = completionsByWeekday.first { $0.value == maxCount }?.key ?? 1
        return calendar.weekdaySymbols[bestDay - 1]
    }
    
    private var last30DaysCompletions: Int {
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        return goal.completedDates.filter { $0 >= thirtyDaysAgo }.count
    }
    
    private var recentCompletions: [Date] {
        goal.completedDates.sorted(by: >).prefix(10).map { $0 }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text(goal.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Statistics & Insights")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(
                            icon: "checkmark.circle.fill",
                            value: "\(goal.totalCompletions)",
                            label: "Total Completions",
                            color: .green
                        )
                        
                        StatCard(
                            icon: "calendar.badge.clock",
                            value: "\(last30DaysCompletions)",
                            label: "Last 30 Days",
                            color: .blue
                        )
                        
                        StatCard(
                            icon: "flame.fill",
                            value: "\(goal.longestStreak)",
                            label: "Longest Streak",
                            color: .orange
                        )
                        
                        StatCard(
                            icon: "percent",
                            value: String(format: "%.0f%%", goal.completionRate * 100),
                            label: "Completion Rate",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                    
                    // Best Day Analysis
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Weekly Pattern")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            ForEach(1...7, id: \.self) { weekday in
                                WeekdayBar(
                                    weekday: Calendar.current.weekdaySymbols[weekday - 1],
                                    count: completionsByWeekday[weekday] ?? 0,
                                    maxCount: completionsByWeekday.values.max() ?? 1,
                                    isBest: (completionsByWeekday[weekday] ?? 0) == (completionsByWeekday.values.max() ?? 0) && (completionsByWeekday.values.max() ?? 0) > 0
                                )
                            }
                        }
                        .padding()
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                        
                        if let bestDay = completionsByWeekday.values.max(), bestDay > 0 {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                                Text("You complete this goal most often on \(bestWeekday)s!")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Time Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Timeline")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            TimelineRow(
                                icon: "calendar.badge.plus",
                                label: "Created",
                                value: goal.createdDate.formatted(date: .abbreviated, time: .omitted),
                                color: .blue
                            )
                            
                            if let firstCompletion = goal.completedDates.min() {
                                TimelineRow(
                                    icon: "checkmark.circle",
                                    label: "First Completion",
                                    value: firstCompletion.formatted(date: .abbreviated, time: .omitted),
                                    color: .green
                                )
                            }
                            
                            if let lastCompletion = goal.completedDates.max() {
                                let daysAgo = Calendar.current.dateComponents([.day], from: lastCompletion, to: Date()).day ?? 0
                                TimelineRow(
                                    icon: "clock",
                                    label: "Last Completion",
                                    value: "\(daysAgo) day\(daysAgo == 1 ? "" : "s") ago",
                                    color: .orange
                                )
                            }
                            
                            if let targetDate = goal.targetDate {
                                TimelineRow(
                                    icon: "flag.checkered",
                                    label: "Target Date",
                                    value: targetDate.formatted(date: .abbreviated, time: .omitted),
                                    color: .purple
                                )
                            }
                        }
                        .padding()
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                    
                    // Recent Completions
                    if !recentCompletions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Completions")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(recentCompletions, id: \.self) { date in
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.caption)
                                            .foregroundStyle(.green)
                                        
                                        Text(date.formatted(date: .abbreviated, time: .omitted))
                                            .font(.subheadline)
                                        
                                        Spacer()
                                        
                                        let daysAgo = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
                                        Text(daysAgo == 0 ? "Today" : "\(daysAgo)d ago")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    if date != recentCompletions.last {
                                        Divider()
                                    }
                                }
                            }
                            .padding()
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                        }
                    }
                    
                    // Points Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Rewards")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 16) {
                            VStack(spacing: 4) {
                                Text("\(goal.pointValue)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.orange)
                                
                                Text("Per Completion")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            
                            Divider()
                            
                            VStack(spacing: 4) {
                                Text("\(goal.totalPointsEarned)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.yellow)
                                
                                Text("Total Earned")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.yellow.opacity(0.2), Color.orange.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Goal Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Weekday Bar

struct WeekdayBar: View {
    let weekday: String
    let count: Int
    let maxCount: Int
    let isBest: Bool
    
    private var progress: Double {
        guard maxCount > 0 else { return 0 }
        return Double(count) / Double(maxCount)
    }
    
    var body: some View {
        HStack {
            Text(String(weekday.prefix(3)))
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 35, alignment: .leading)
                .foregroundStyle(isBest ? .orange : .primary)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(uiColor: .systemGray5))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isBest ? Color.orange.gradient : Color.blue.gradient)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 20)
            
            Text("\(count)")
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 25, alignment: .trailing)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Timeline Row

struct TimelineRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
    }
}

// MARK: - Edit Goal View

struct EditGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var appSettings
    @Bindable var goal: Goal
    
    @State private var title: String
    @State private var hasHabit: Bool
    @State private var habitFrequency: HabitFrequency
    @State private var shareCompletionToChat: Bool
    @State private var pointValue: Int
    @State private var hasDeadline: Bool
    @State private var targetDate: Date
    
    init(goal: Goal) {
        self.goal = goal
        _title = State(initialValue: goal.title)
        _hasHabit = State(initialValue: goal.hasHabit)
        _habitFrequency = State(initialValue: goal.habitFrequency ?? .daily)
        _shareCompletionToChat = State(initialValue: goal.shareCompletionToChat)
        _pointValue = State(initialValue: goal.pointValue)
        _hasDeadline = State(initialValue: goal.targetDate != nil)
        _targetDate = State(initialValue: goal.targetDate ?? Date().addingTimeInterval(7 * 24 * 60 * 60))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Goal Title", text: $title)
                }
                
                Section {
                    Toggle("Track as Habit", isOn: $hasHabit)
                    
                    if hasHabit {
                        Picker("Frequency", selection: $habitFrequency) {
                            ForEach(HabitFrequency.allCases, id: \.self) { frequency in
                                Text(frequency.rawValue).tag(frequency)
                            }
                        }
                        
                        Toggle("Share completions to chat", isOn: $shareCompletionToChat)
                    }
                } header: {
                    Text("Habit Tracking")
                } footer: {
                    Text("Habits help track progress over time with simple checkmarks")
                }
                
                Section {
                    Stepper("Point Value: \(pointValue)", value: $pointValue, in: 1...100, step: 5)
                    
                    Text("Earn \(pointValue) points each time this goal is completed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Rewards")
                }
                
                Section {
                    Toggle("Set Target Date", isOn: $hasDeadline)
                    
                    if hasDeadline {
                        DatePicker("Target Date", selection: $targetDate, in: Date()..., displayedComponents: .date)
                        
                        if let days = Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day {
                            Text("\(days) days from now")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Deadline")
                } footer: {
                    Text("Set a target date to stay motivated and track progress")
                }
                
                Section {
                    HStack {
                        Text("Created by")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(goal.createdByChildName)
                    }
                    
                    if let parentName = goal.createdByParentName {
                        HStack {
                            Text("Assigned by")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(parentName)
                        }
                    }
                    
                    HStack {
                        Text("Status")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(goal.status.rawValue)
                            .foregroundStyle(Color(goal.status.color))
                    }
                } header: {
                    Text("Goal Information")
                }
            }
            .navigationTitle("Edit Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let titleChanged = goal.title != trimmedTitle
        
        goal.title = trimmedTitle
        goal.hasHabit = hasHabit
        goal.habitFrequency = hasHabit ? habitFrequency : nil
        goal.shareCompletionToChat = shareCompletionToChat
        goal.pointValue = pointValue
        goal.targetDate = hasDeadline ? targetDate : nil
        
        // If significant changes were made, notify via chat
        if titleChanged {
            // Could add a chat notification here if desired
        }
        
        dismiss()
    }
}

#Preview {
    GoalsView()
        .environment(AppSettings())
        .modelContainer(for: [FamilyMember.self, ChatMessage.self, CalendarEvent.self, Goal.self])
}
