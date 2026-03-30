//
//  SettingsView.swift
//  FamSphere
//
//  Created by Vinays Mac on 12/30/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(AppSettings.self) private var appSettings
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \ChatMessage.timestamp, order: .forward)
    private var messages: [ChatMessage]
    
    @State private var showingExportOptions = false
    @State private var showingResetAlert = false
    
    var body: some View {
        @Bindable var settings = appSettings
        
        NavigationStack {
            Form {
                // TESTING: Quick User Switcher (for local testing only)
                #if DEBUG
                Section {
                    Text("🧪 Testing Mode (Debug Only)")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    
                    NavigationLink {
                        UserSwitcherView()
                    } label: {
                        HStack {
                            Label("Switch User (Local Testing)", systemImage: "person.2.crop.square.stack")
                            Spacer()
                            Text(appSettings.currentUserName)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Local Testing")
                } footer: {
                    Text("For production, use Family Sharing below to invite real family members")
                        .font(.caption)
                }
                #endif
                
                // Profile Section
                Section("Profile") {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(appSettings.currentUserName)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Role")
                        Spacer()
                        Text(appSettings.currentUserRole == .parent ? "Parent" : "Child")
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Family Sharing Section (Production)
                Section {
                    NavigationLink {
                        FamilyManagementView()
                    } label: {
                        HStack {
                            Label("Family Sharing", systemImage: "person.2.circle.fill")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                } header: {
                    Text("Family Management")
                } footer: {
                    Text("Invite family members to join via their Apple ID. They'll be able to access shared events, goals, and chat on their own devices.")
                }
                
                // Local Family Members (for reference)
                if appSettings.currentUserRole == .parent {
                    Section {
                        NavigationLink {
                            ManageFamilyView()
                        } label: {
                            Label("Manage Local Members", systemImage: "person.3.fill")
                        }
                    } header: {
                        Text("Local Device")
                    } footer: {
                        Text("Manage family members stored on this device only")
                    }
                }
                
                // Preferences Section
                Section("Preferences") {
                    Toggle("Notifications", isOn: $settings.notificationsEnabled)
                    Toggle("iMessage Sharing", isOn: $settings.iMessageSharingEnabled)
                    
                    Picker("Appearance", selection: $settings.appearanceMode) {
                        ForEach(AppearanceMode.allCases, id: \.self) { mode in
                            HStack {
                                switch mode {
                                case .system:
                                    Label(mode.rawValue, systemImage: "circle.lefthalf.filled")
                                case .light:
                                    Label(mode.rawValue, systemImage: "sun.max.fill")
                                case .dark:
                                    Label(mode.rawValue, systemImage: "moon.fill")
                                }
                            }
                            .tag(mode)
                        }
                    }
                }
                
                // iCloud Sync Section
                Section {
                    NavigationLink {
                        CloudSyncStatusView()
                    } label: {
                        HStack {
                            Label("iCloud Sync", systemImage: "icloud")
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.caption)
                        }
                    }
                } header: {
                    Text("Sync")
                } footer: {
                    Text("Your family data syncs automatically across all devices signed in with the same Apple ID")
                }
                
                // Data Section
                Section("Data") {
                    Button {
                        showingExportOptions = true
                    } label: {
                        Label("Export Chat History", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(role: .destructive) {
                        showingResetAlert = true
                    } label: {
                        Label("Reset App Data", systemImage: "trash")
                    }
                }
                
                // About Section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    NavigationLink {
                        PrivacyInfoView()
                    } label: {
                        Label("Privacy Information", systemImage: "hand.raised.fill")
                    }
                    
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About FamSphere", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog("Export Chat History", isPresented: $showingExportOptions) {
                Button("Export as Text") {
                    exportChatAsText()
                }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Reset App Data", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetAppData()
                }
            } message: {
                Text("This will delete all messages, events, goals, and family members. This action cannot be undone.")
            }
        }
    }
    
    private func exportChatAsText() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        var exportText = "FamSphere Chat Export\n"
        exportText += "Generated: \(dateFormatter.string(from: Date()))\n"
        exportText += "===================\n\n"
        
        for message in messages {
            let timestamp = dateFormatter.string(from: message.timestamp)
            let important = message.isImportant ? " ⭐️" : ""
            exportText += "[\(timestamp)] \(message.authorName)\(important)\n"
            exportText += "\(message.content)\n\n"
        }
        
        // Share using system share sheet
        let activityVC = UIActivityViewController(
            activityItems: [exportText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            activityVC.popoverPresentationController?.sourceView = rootVC.view
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func resetAppData() {
        // Delete all data
        try? modelContext.delete(model: ChatMessage.self)
        try? modelContext.delete(model: CalendarEvent.self)
        try? modelContext.delete(model: Goal.self)
        try? modelContext.delete(model: FamilyMember.self)
        
        // Reset app settings
        appSettings.isOnboarded = false
    }
}

// MARK: - Privacy Info View

struct PrivacyInfoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Information")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)
                
                privacySection(
                    title: "Your Data Stays Private",
                    icon: "lock.shield.fill",
                    description: "All data in FamSphere is stored locally on your device. Nothing is sent to external servers or cloud services."
                )
                
                privacySection(
                    title: "No Tracking",
                    icon: "eye.slash.fill",
                    description: "FamSphere does not track your activity, collect analytics, or share information with third parties."
                )
                
                privacySection(
                    title: "Family Only",
                    icon: "person.2.fill",
                    description: "This app is designed for your family only. There are no public features, no strangers, and no social network components."
                )
                
                privacySection(
                    title: "iMessage Integration",
                    icon: "message.fill",
                    description: "When you choose to share a message via iMessage, you manually control the send button. FamSphere never automatically sends messages."
                )
                
                privacySection(
                    title: "Data Control",
                    icon: "slider.horizontal.3",
                    description: "You can export your chat history or reset all app data at any time from Settings."
                )
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func privacySection(title: String, icon: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - About View

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "circle.hexagongrid.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.top, 20)
                
                VStack(spacing: 8) {
                    Text("FamSphere")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Version 1.0.0")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("A Shared Space for Your Family")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.bottom, 4)
                    
                    Text("FamSphere is a private, family-only app designed for healthy communication, planning, and personal growth.")
                        .foregroundStyle(.secondary)
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    featureRow(icon: "bubble.left.and.bubble.right.fill", title: "Family Chat", description: "Stay connected with private messaging")
                    
                    featureRow(icon: "calendar", title: "Shared Calendar", description: "Coordinate schedules and events")
                    
                    featureRow(icon: "target", title: "Personal Goals", description: "Track habits and celebrate progress")
                    
                    featureRow(icon: "hand.raised.fill", title: "Privacy First", description: "No ads, no tracking, no social network")
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Cloud Sync Status View

struct CloudSyncStatusView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var familyMembers: [FamilyMember]
    @Query private var messages: [ChatMessage]
    @Query private var events: [CalendarEvent]
    @Query private var goals: [Goal]
    
    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "icloud.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("iCloud Sync Active")
                            .font(.headline)
                        
                        Text("Data syncs across your family's devices")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.leading, 8)
                }
                .padding(.vertical, 8)
            }
            
            Section("Synced Data") {
                syncDataRow(icon: "person.2.fill", label: "Family Members", count: familyMembers.count)
                syncDataRow(icon: "bubble.left.and.bubble.right.fill", label: "Messages", count: messages.count)
                syncDataRow(icon: "calendar", label: "Events", count: events.count)
                syncDataRow(icon: "target", label: "Goals", count: goals.count)
            }
            
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Label("How it works", systemImage: "info.circle")
                        .font(.headline)
                    
                    Text("When you sign in with your Apple ID on multiple devices, FamSphere automatically syncs your family's data through iCloud.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("All family members need to be signed in with the same Apple ID or part of the same Family Sharing group to see shared data.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            } header: {
                Text("About iCloud Sync")
            }
            
            Section {
                HStack(spacing: 12) {
                    Image(systemName: "lock.shield.fill")
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("End-to-End Encryption")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text("Your family data is encrypted and private")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("iCloud Sync")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func syncDataRow(icon: String, label: String, count: Int) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            Text(label)
            
            Spacer()
            
            Text("\(count)")
                .foregroundStyle(.secondary)
                .font(.subheadline)
        }
    }
}

// MARK: - User Switcher View (Testing Utility)

struct UserSwitcherView: View {
    @Environment(AppSettings.self) private var appSettings
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FamilyMember.name) private var familyMembers: [FamilyMember]
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingAddMember = false
    
    private var parents: [FamilyMember] {
        familyMembers.filter { $0.role == .parent }
    }
    
    private var children: [FamilyMember] {
        familyMembers.filter { $0.role == .child }
    }
    
    var body: some View {
        Group {
            if familyMembers.isEmpty {
                emptyStateView
            } else {
                userListView
            }
        }
        .navigationTitle("Switch User")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddMember = true
                } label: {
                    Label("Add User", systemImage: "plus.circle.fill")
                        .labelStyle(.iconOnly)
                }
            }
        }
        .sheet(isPresented: $showingAddMember) {
            AddFamilyMemberView()
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
                
                VStack(spacing: 8) {
                    Text("No Family Members Yet")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Add your first parent or child to get started with FamSphere.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            
            Button {
                showingAddMember = true
            } label: {
                Label("Add First User", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
    }
    
    // MARK: - User List View
    
    private var userListView: some View {
        List {
            // Testing Mode Banner
            Section {
                HStack(spacing: 12) {
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .foregroundStyle(.orange)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Testing Mode")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text("Quickly switch between family members to test different views and permissions.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            
            // Current User Indicator
            if !appSettings.currentUserName.isEmpty {
                Section {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Currently Signed In")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text(appSettings.currentUserName)
                                .font(.headline)
                            
                            Text(appSettings.currentUserRole == .parent ? "Parent" : "Child")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                            .font(.title3)
                    }
                    .padding(.vertical, 4)
                }
            }
            
            // Parents Section
            if !parents.isEmpty {
                Section {
                    ForEach(parents) { member in
                        UserRowView(
                            member: member,
                            isCurrent: member.name == appSettings.currentUserName
                        ) {
                            switchToUser(member)
                        }
                    }
                } header: {
                    Label("Parents", systemImage: "person.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
            }
            
            // Children Section
            if !children.isEmpty {
                Section {
                    ForEach(children) { member in
                        UserRowView(
                            member: member,
                            isCurrent: member.name == appSettings.currentUserName
                        ) {
                            switchToUser(member)
                        }
                    }
                } header: {
                    Label("Children", systemImage: "figure.2.and.child.holdinghands")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
            }
            
            // Quick Add Section
            Section {
                Button {
                    showingAddMember = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                            .font(.title3)
                        
                        Text("Add New Family Member")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
            
            // Info Section
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Label("How It Works", systemImage: "info.circle")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("Tap any family member to instantly switch to their account. All views will update to show their role and permissions.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("This is a testing utility to help you explore how FamSphere works for different family members.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    // MARK: - Actions
    
    private func switchToUser(_ member: FamilyMember) {
        print("🔄 Switching to user: \(member.name), role: \(member.role.rawValue)")
        appSettings.currentUserName = member.name
        appSettings.currentUserRole = member.role
        print("✅ Updated settings - Name: \(appSettings.currentUserName), Role: \(appSettings.currentUserRole.rawValue)")
        dismiss()
    }
}

// MARK: - User Row View

struct UserRowView: View {
    let member: FamilyMember
    let isCurrent: Bool
    let action: () -> Void
    
    private var roleIcon: String {
        member.role == .parent ? "person.fill" : "figure.child"
    }
    
    private var roleColor: Color {
        member.role == .parent ? .blue : .orange
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Avatar
                Circle()
                    .fill(Color(hex: member.colorHex) ?? roleColor)
                    .frame(width: 44, height: 44)
                    .overlay {
                        Text(String(member.name.prefix(1)))
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    .overlay(alignment: .bottomTrailing) {
                        if isCurrent {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.white)
                                .background(Circle().fill(.green))
                                .offset(x: 2, y: 2)
                        }
                    }
                
                // User Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(member.name)
                            .font(.headline)
                        
                        if isCurrent {
                            Text("Current")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(.green))
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: roleIcon)
                            .font(.caption2)
                        
                        Text(member.role == .parent ? "Parent" : "Child")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Action Indicator
                if !isCurrent {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Manage Family View

struct ManageFamilyView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    @Query(sort: \FamilyMember.name) private var familyMembers: [FamilyMember]
    @Query private var allGoals: [Goal]
    @Query private var allEvents: [CalendarEvent]

    @State private var showingAddMember = false
    @State private var memberToDelete: FamilyMember?
    @State private var showingDeleteConfirmation = false

    var body: some View {
        List {
            Section {
                Text("Everyone using this device and signed into this Apple ID can access FamSphere.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Text("How It Works")
            }

            Section {
                ForEach(familyMembers) { member in
                    let goalCount = allGoals.filter { $0.createdByChildName == member.name }.count
                    let eventCount = allEvents.filter { $0.createdByName == member.name }.count

                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color(hex: member.colorHex) ?? .blue)
                            .frame(width: 40, height: 40)
                            .overlay {
                                Text(String(member.name.prefix(1)))
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(member.name)
                                .font(.headline)

                            Text(member.role == .parent ? "Parent" : "Child")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            if goalCount > 0 || eventCount > 0 {
                                HStack(spacing: 8) {
                                    if goalCount > 0 {
                                        Label("\(goalCount)", systemImage: "target")
                                            .font(.caption2)
                                    }
                                    if eventCount > 0 {
                                        Label("\(eventCount)", systemImage: "calendar")
                                            .font(.caption2)
                                    }
                                }
                                .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()

                        if member.name != appSettings.currentUserName {
                            Button(role: .destructive) {
                                memberToDelete = member
                                showingDeleteConfirmation = true
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.plain)
                        } else {
                            Text("Current")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(.green))
                        }
                    }
                }
            } header: {
                Text("Family Members (\(familyMembers.count))")
            } footer: {
                Text("Swipe left on a member or tap the trash icon to remove them. You cannot remove the currently signed-in user.")
                    .font(.caption)
            }

            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Adding Family Members", systemImage: "info.circle")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text("Tap the + button to add a new family member. They can then switch to their profile using Settings → Switch User.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("All family members on this device will share the same data through iCloud.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Family Members")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddMember = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddMember) {
            AddFamilyMemberView()
        }
        .alert("Delete Family Member?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                memberToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let member = memberToDelete {
                    deleteMember(member)
                }
            }
        } message: {
            Text({
                guard let member = memberToDelete else { return "" }

                let goalCount = allGoals.filter { $0.createdByChildName == member.name }.count
                let eventCount = allEvents.filter { $0.createdByName == member.name }.count

                var parts: [String] = []

                if goalCount > 0 {
                    parts.append("\(goalCount) goal\(goalCount == 1 ? "" : "s")")
                }
                if eventCount > 0 {
                    parts.append("\(eventCount) event\(eventCount == 1 ? "" : "s")")
                }

                var message = "This will permanently delete \(member.name)"

                if !parts.isEmpty {
                    message += " and their " + parts.joined(separator: " and ")
                }

                return message + ". This action cannot be undone."
            }())
        }
    }

    private func deleteMember(_ member: FamilyMember) {
        allGoals.filter { $0.createdByChildName == member.name }
            .forEach { modelContext.delete($0) }

        allEvents.filter { $0.createdByName == member.name }
            .forEach { modelContext.delete($0) }

        modelContext.delete(member)
        memberToDelete = nil
    }
}


// MARK: - Add Family Member View

struct AddFamilyMemberView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FamilyMember.name) private var existingMembers: [FamilyMember]
    
    @State private var name = ""
    @State private var role: MemberRole = .child
    @State private var selectedColorHex: String?
    
    @FocusState private var nameFieldFocused: Bool
    
    private let availableColors = [
        "#F5A623", "#E74C3C", "#3498DB", "#2ECC71", 
        "#9B59B6", "#1ABC9C", "#E67E22", "#34495E",
        "#F39C12", "#16A085", "#8E44AD", "#C0392B"
    ]
    
    private var usedColors: Set<String> {
        Set(existingMembers.map { $0.colorHex })
    }
    
    private var suggestedColor: String {
        // Find first unused color, or cycle back to start
        availableColors.first { !usedColors.contains($0) } ?? availableColors[existingMembers.count % availableColors.count]
    }
    
    private var finalColorHex: String {
        selectedColorHex ?? suggestedColor
    }
    
    private var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var nameAlreadyExists: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return existingMembers.contains { $0.name.lowercased() == trimmedName.lowercased() }
    }
    
    private var canSave: Bool {
        isNameValid && !nameAlreadyExists
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Preview Section
                Section {
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 12) {
                            Circle()
                                .fill(Color(hex: finalColorHex) ?? .blue)
                                .frame(width: 80, height: 80)
                                .overlay {
                                    if isNameValid {
                                        Text(String(name.prefix(1).uppercased()))
                                            .font(.system(size: 36, weight: .bold))
                                            .foregroundStyle(.white)
                                    } else {
                                        Image(systemName: role == .parent ? "person.fill" : "figure.child")
                                            .font(.system(size: 36))
                                            .foregroundStyle(.white)
                                    }
                                }
                            
                            VStack(spacing: 4) {
                                Text(isNameValid ? name : "New User")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                HStack(spacing: 4) {
                                    Image(systemName: role == .parent ? "person.fill" : "figure.child")
                                        .font(.caption2)
                                    Text(role == .parent ? "Parent" : "Child")
                                        .font(.caption)
                                }
                                .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // Name Section
                Section {
                    TextField("Name", text: $name)
                        .textContentType(.name)
                        .autocorrectionDisabled()
                        .focused($nameFieldFocused)
                    
                    if nameAlreadyExists {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                            Text("A family member with this name already exists")
                                .font(.caption)
                        }
                        .foregroundStyle(.red)
                    }
                } header: {
                    Text("Name")
                } footer: {
                    Text("Enter the family member's first name or nickname")
                }
                
                // Role Section
                Section {
                    Picker("Role", selection: $role) {
                        Text("Parent").tag(MemberRole.parent)
                        Text("Child").tag(MemberRole.child)
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Role")
                } footer: {
                    Text(role == .parent ? "Parents can approve goals and manage the family" : "Children can create goals and track their progress")
                }
                
                // Color Section
                Section {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 55))], spacing: 12) {
                        ForEach(availableColors, id: \.self) { hex in
                            ColorSelectionButton(
                                colorHex: hex,
                                isSelected: finalColorHex == hex,
                                isUsed: usedColors.contains(hex),
                                isSuggested: hex == suggestedColor && selectedColorHex == nil
                            ) {
                                if selectedColorHex == hex {
                                    selectedColorHex = nil  // Deselect to use auto
                                } else {
                                    selectedColorHex = hex
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Profile Color")
                } footer: {
                    if selectedColorHex == nil {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.caption2)
                            Text("Auto-selected color (tap any color to customize)")
                                .font(.caption)
                        }
                    } else {
                        Text("Tap the selected color again to use auto-selection")
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Add Family Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addMember()
                    }
                    .disabled(!canSave)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                nameFieldFocused = true
            }
        }
    }
    
    private func addMember() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let member = FamilyMember(
            name: trimmedName,
            role: role,
            colorHex: finalColorHex
        )
        
        modelContext.insert(member)
        
        print("✅ Added new family member: \(trimmedName) (\(role.rawValue)) - Color: \(finalColorHex)")
        
        dismiss()
    }
}

// MARK: - Color Selection Button

struct ColorSelectionButton: View {
    let colorHex: String
    let isSelected: Bool
    let isUsed: Bool
    let isSuggested: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color(hex: colorHex) ?? .blue)
                .frame(width: 55, height: 55)
                .overlay {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    } else if isSuggested {
                        Image(systemName: "sparkles")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                }
                .overlay {
                    if isUsed && !isSelected {
                        Circle()
                            .strokeBorder(Color.secondary.opacity(0.3), lineWidth: 2)
                    }
                }
                .overlay {
                    if isSelected {
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 3)
                            .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                    }
                }
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView()
        .environment(AppSettings())
        .modelContainer(for: [FamilyMember.self, ChatMessage.self, CalendarEvent.self, Goal.self])
}
