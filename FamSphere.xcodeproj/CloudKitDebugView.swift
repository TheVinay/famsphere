//
//  CloudKitDebugView.swift
//  FamSphere
//
//  Debug view to help diagnose CloudKit issues
//

import SwiftUI
import CloudKit

#if DEBUG

struct CloudKitDebugView: View {
    @EnvironmentObject private var cloudKitManager: CloudKitSharingManager
    @State private var accountStatus: CKAccountStatus?
    @State private var isCheckingStatus = false
    @State private var errorMessage: String?
    @State private var containerID = "iCloud.VinPersonal.FamSphere"
    @State private var debugLog: [String] = []
    
    var body: some View {
        NavigationStack {
            List {
                // Account Status Section
                Section {
                    HStack {
                        Text("iCloud Status")
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        if isCheckingStatus {
                            ProgressView()
                        } else if let status = accountStatus {
                            statusBadge(for: status)
                        }
                    }
                    
                    if let status = accountStatus {
                        statusDescription(for: status)
                    }
                    
                    Button {
                        checkAccountStatus()
                    } label: {
                        Label("Check Account Status", systemImage: "arrow.clockwise")
                    }
                } header: {
                    Text("iCloud Account")
                }
                
                // Container Information
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Container ID")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(containerID)
                            .font(.system(.caption, design: .monospaced))
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    
                    Button {
                        UIPasteboard.general.string = containerID
                    } label: {
                        Label("Copy Container ID", systemImage: "doc.on.doc")
                    }
                } header: {
                    Text("CloudKit Container")
                }
                
                // Current Share Status
                Section {
                    HStack {
                        Text("Family Share")
                        Spacer()
                        Text(cloudKitManager.currentFamilyShare != nil ? "Active" : "None")
                            .foregroundStyle(cloudKitManager.currentFamilyShare != nil ? .green : .secondary)
                    }
                    
                    HStack {
                        Text("Is Owner")
                        Spacer()
                        Text(cloudKitManager.isFamilyOwner ? "Yes" : "No")
                            .foregroundStyle(cloudKitManager.isFamilyOwner ? .blue : .secondary)
                    }
                    
                    HStack {
                        Text("Participants")
                        Spacer()
                        Text("\(cloudKitManager.familyParticipants.count)")
                            .foregroundStyle(.secondary)
                    }
                    
                    if let share = cloudKitManager.currentFamilyShare {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Share URL")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            if let url = share.url {
                                Text(url.absoluteString)
                                    .font(.system(.caption2, design: .monospaced))
                                    .lineLimit(3)
                            } else {
                                Text("No URL available")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                } header: {
                    Text("Share Status")
                }
                
                // Test Operations
                Section {
                    Button {
                        testCreateShare()
                    } label: {
                        Label("Test Create Family Share", systemImage: "plus.circle")
                    }
                    
                    Button {
                        testGenerateInvitation()
                    } label: {
                        Label("Test Generate Invitation", systemImage: "link")
                    }
                    
                    Button {
                        testFetchParticipants()
                    } label: {
                        Label("Test Fetch Participants", systemImage: "person.3")
                    }
                    
                    Button(role: .destructive) {
                        resetShareStatus()
                    } label: {
                        Label("Reset Share Status", systemImage: "arrow.counterclockwise")
                    }
                } header: {
                    Text("Test Operations")
                } footer: {
                    Text("These operations help test CloudKit functionality")
                }
                
                // Debug Log
                if !debugLog.isEmpty {
                    Section {
                        ForEach(Array(debugLog.enumerated()), id: \.offset) { index, log in
                            Text(log)
                                .font(.system(.caption, design: .monospaced))
                                .textSelection(.enabled)
                        }
                        
                        Button {
                            debugLog.removeAll()
                        } label: {
                            Label("Clear Log", systemImage: "trash")
                                .foregroundStyle(.red)
                        }
                    } header: {
                        Text("Debug Log")
                    }
                }
                
                // Error Message
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    } header: {
                        Text("Last Error")
                    }
                }
                
                // Quick Help
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        helpRow(
                            status: "Available",
                            color: .green,
                            meaning: "CloudKit is working correctly"
                        )
                        
                        Divider()
                        
                        helpRow(
                            status: "No Account",
                            color: .red,
                            meaning: "Not signed into iCloud in Settings"
                        )
                        
                        Divider()
                        
                        helpRow(
                            status: "Restricted",
                            color: .orange,
                            meaning: "iCloud access restricted (Screen Time, MDM)"
                        )
                        
                        Divider()
                        
                        helpRow(
                            status: "Temporarily Unavailable",
                            color: .yellow,
                            meaning: "iCloud services are down or network issues"
                        )
                    }
                    .font(.caption)
                    .padding(.vertical, 8)
                } header: {
                    Text("Status Meanings")
                }
            }
            .navigationTitle("CloudKit Debug")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        // Close view if presented as sheet
                    }
                }
            }
            .task {
                checkAccountStatus()
            }
        }
    }
    
    // MARK: - Status Badge
    
    @ViewBuilder
    private func statusBadge(for status: CKAccountStatus) -> some View {
        switch status {
        case .available:
            Label("Available", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.caption)
        case .noAccount:
            Label("No Account", systemImage: "xmark.circle.fill")
                .foregroundStyle(.red)
                .font(.caption)
        case .restricted:
            Label("Restricted", systemImage: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .font(.caption)
        case .couldNotDetermine:
            Label("Unknown", systemImage: "questionmark.circle.fill")
                .foregroundStyle(.gray)
                .font(.caption)
        case .temporarilyUnavailable:
            Label("Unavailable", systemImage: "exclamationmark.circle.fill")
                .foregroundStyle(.yellow)
                .font(.caption)
        @unknown default:
            Label("Unknown", systemImage: "questionmark.circle.fill")
                .foregroundStyle(.gray)
                .font(.caption)
        }
    }
    
    @ViewBuilder
    private func statusDescription(for status: CKAccountStatus) -> some View {
        let (text, color): (String, Color) = {
            switch status {
            case .available:
                return ("iCloud is available and ready to use", .green)
            case .noAccount:
                return ("Not signed into iCloud. Go to Settings → [Your Name] to sign in", .red)
            case .restricted:
                return ("iCloud access is restricted by Screen Time or MDM", .orange)
            case .couldNotDetermine:
                return ("Could not determine iCloud status", .gray)
            case .temporarilyUnavailable:
                return ("iCloud is temporarily unavailable. Check internet connection", .yellow)
            @unknown default:
                return ("Unknown iCloud status", .gray)
            }
        }()
        
        Text(text)
            .font(.caption)
            .foregroundStyle(color)
    }
    
    @ViewBuilder
    private func helpRow(status: String, color: Color, meaning: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(status)
                    .fontWeight(.semibold)
                Text(meaning)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - Test Operations
    
    private func checkAccountStatus() {
        isCheckingStatus = true
        errorMessage = nil
        
        Task {
            do {
                let status = try await cloudKitManager.checkAccountStatus()
                
                await MainActor.run {
                    self.accountStatus = status
                    self.isCheckingStatus = false
                    addLog("✅ Account status: \(status)")
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isCheckingStatus = false
                    addLog("❌ Error checking status: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func testCreateShare() {
        errorMessage = nil
        addLog("🔵 Testing create family share...")
        
        Task {
            do {
                let share = try await cloudKitManager.createFamilyShare()
                
                await MainActor.run {
                    addLog("✅ Family share created: \(share.recordID)")
                    if let url = share.url {
                        addLog("   URL: \(url.absoluteString)")
                    } else {
                        addLog("   ⚠️ No URL in share")
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    addLog("❌ Create failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func testGenerateInvitation() {
        errorMessage = nil
        addLog("🔵 Testing generate invitation...")
        
        Task {
            do {
                let url = try await cloudKitManager.generateInvitationLink()
                
                await MainActor.run {
                    addLog("✅ Invitation generated: \(url.absoluteString)")
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    addLog("❌ Generation failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func testFetchParticipants() {
        errorMessage = nil
        addLog("🔵 Testing fetch participants...")
        
        Task {
            do {
                try await cloudKitManager.fetchParticipants()
                
                await MainActor.run {
                    addLog("✅ Fetched \(cloudKitManager.familyParticipants.count) participants")
                    
                    for (index, participant) in cloudKitManager.familyParticipants.enumerated() {
                        let name = participant.userIdentity.nameComponents
                            .flatMap { PersonNameComponentsFormatter().string(from: $0) }
                            ?? "Unknown"
                        addLog("   \(index + 1). \(name) (\(participant.role == .owner ? "Owner" : "Member"))")
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    addLog("❌ Fetch failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func resetShareStatus() {
        cloudKitManager.leaveFamily()
        addLog("🔄 Reset share status")
    }
    
    private func addLog(_ message: String) {
        let timestamp = DateFormatter.localizedString(
            from: Date(),
            dateStyle: .none,
            timeStyle: .medium
        )
        debugLog.append("[\(timestamp)] \(message)")
        print(message)
    }
}

#Preview {
    CloudKitDebugView()
        .environmentObject(CloudKitSharingManager.shared)
}

#endif
