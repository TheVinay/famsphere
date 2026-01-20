//
//  FamilyManagementView.swift
//  FamSphere
//
//  Created by Vinays Mac on 1/19/26.
//

import SwiftUI
import CloudKit

struct FamilyManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cloudKitManager: CloudKitSharingManager
    @Environment(AppSettings.self) private var appSettings
    
    @State private var showingInvitationSheet = false
    @State private var showingShareSheet = false
    @State private var invitationURL: URL?
    @State private var isLoadingShare = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            List {
                // Family Share Status
                Section {
                    if cloudKitManager.isFamilyOwner {
                        HStack {
                            Image(systemName: "person.badge.key.fill")
                                .foregroundStyle(.blue)
                            Text("You are the Family Organizer")
                                .fontWeight(.medium)
                        }
                    } else if cloudKitManager.currentFamilyShare != nil {
                        HStack {
                            Image(systemName: "person.2.fill")
                                .foregroundStyle(.green)
                            Text("You are a Family Member")
                                .fontWeight(.medium)
                        }
                    } else {
                        HStack {
                            Image(systemName: "person.fill.questionmark")
                                .foregroundStyle(.orange)
                            Text("No Family Sharing Active")
                                .fontWeight(.medium)
                        }
                    }
                } header: {
                    Text("Family Sharing Status")
                }
                
                // Invite Family Members (Owner Only)
                if cloudKitManager.isFamilyOwner {
                    Section {
                        Button {
                            generateInvitation()
                        } label: {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                Text("Invite Family Member")
                                
                                Spacer()
                                
                                if isLoadingShare {
                                    ProgressView()
                                }
                            }
                        }
                        .disabled(isLoadingShare)
                    } header: {
                        Text("Invite Members")
                    } footer: {
                        Text("Send an invitation link to family members. They'll use their Apple ID to join.")
                    }
                }
                
                // Create Family (if not in one)
                if cloudKitManager.currentFamilyShare == nil && !cloudKitManager.isFamilyOwner {
                    Section {
                        Button {
                            createFamily()
                        } label: {
                            HStack {
                                Image(systemName: "person.2.badge.gearshape")
                                Text("Create Family Group")
                                
                                Spacer()
                                
                                if isLoadingShare {
                                    ProgressView()
                                }
                            }
                        }
                        .disabled(isLoadingShare)
                    } footer: {
                        Text("Start a new family group and invite members to join with their Apple IDs")
                    }
                }
                
                // Family Members List
                if !cloudKitManager.familyParticipants.isEmpty {
                    Section {
                        ForEach(cloudKitManager.familyParticipants, id: \.userIdentity.userRecordID) { participant in
                            FamilyMemberRow(participant: participant, isOwner: cloudKitManager.isFamilyOwner)
                        }
                    } header: {
                        Text("Family Members (\(cloudKitManager.familyParticipants.count))")
                    }
                }
                
                // How It Works
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        howItWorksRow(
                            icon: "person.badge.plus",
                            title: "Invite via Apple ID",
                            description: "Family members join using their Apple ID - just like Apple's Family Sharing"
                        )
                        
                        Divider()
                        
                        howItWorksRow(
                            icon: "icloud.fill",
                            title: "Secure Cloud Sync",
                            description: "All family data syncs automatically through iCloud"
                        )
                        
                        Divider()
                        
                        howItWorksRow(
                            icon: "lock.shield.fill",
                            title: "Privacy Protected",
                            description: "Only invited family members can access your shared data"
                        )
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("How Family Sharing Works")
                }
                
                // Error Message
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.subheadline)
                    }
                }
                
                // Leave Family (if member but not owner)
                if !cloudKitManager.isFamilyOwner && cloudKitManager.currentFamilyShare != nil {
                    Section {
                        Button(role: .destructive) {
                            cloudKitManager.leaveFamily()
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Leave Family")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Family Sharing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = invitationURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }
    
    @ViewBuilder
    private func howItWorksRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func createFamily() {
        isLoadingShare = true
        errorMessage = nil
        
        Task {
            do {
                _ = try await cloudKitManager.createFamilyShare()
                isLoadingShare = false
            } catch {
                errorMessage = "Failed to create family: \(error.localizedDescription)"
                isLoadingShare = false
            }
        }
    }
    
    private func generateInvitation() {
        isLoadingShare = true
        errorMessage = nil
        
        Task {
            do {
                let url = try await cloudKitManager.generateInvitationLink()
                invitationURL = url
                isLoadingShare = false
                showingShareSheet = true
            } catch {
                errorMessage = "Failed to generate invitation: \(error.localizedDescription)"
                isLoadingShare = false
            }
        }
    }
}

// MARK: - Family Member Row

struct FamilyMemberRow: View {
    let participant: CKShare.Participant
    let isOwner: Bool
    
    @EnvironmentObject private var cloudKitManager: CloudKitSharingManager
    @State private var showingRemoveAlert = false
    
    private var participantName: String {
        if let name = participant.userIdentity.nameComponents {
            return PersonNameComponentsFormatter().string(from: name)
        }
        return "Family Member"
    }
    
    private var isCurrentUserOwner: Bool {
        participant.role == .owner
    }
    
    var body: some View {
        HStack {
            Image(systemName: isCurrentUserOwner ? "person.badge.key.fill" : "person.fill")
                .foregroundStyle(isCurrentUserOwner ? .blue : .secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(participantName)
                    .font(.body)
                
                Text(isCurrentUserOwner ? "Organizer" : participantStatus)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Remove button (owner can remove others)
            if isOwner && !isCurrentUserOwner {
                Button(role: .destructive) {
                    showingRemoveAlert = true
                } label: {
                    Image(systemName: "person.badge.minus")
                        .foregroundStyle(.red)
                }
                .buttonStyle(.borderless)
            }
        }
        .alert("Remove Family Member?", isPresented: $showingRemoveAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) {
                removeParticipant()
            }
        } message: {
            Text("This family member will lose access to shared data.")
        }
    }
    
    private var participantStatus: String {
        switch participant.acceptanceStatus {
        case .pending:
            return "Invitation pending"
        case .accepted:
            return "Active member"
        case .removed:
            return "Removed"
        case .unknown:
            return "Unknown status"
        @unknown default:
            return "Unknown status"
        }
    }
    
    private func removeParticipant() {
        Task {
            try? await cloudKitManager.removeParticipant(participant)
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    FamilyManagementView()
        .environment(AppSettings())
        .environmentObject(CloudKitSharingManager.shared)
}
