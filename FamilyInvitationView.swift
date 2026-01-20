//
//  FamilyInvitationView.swift
//  FamSphere
//
//  UI for inviting family members via CloudKit sharing
//

import SwiftUI
import CloudKit

struct FamilyInvitationView: View {
    @EnvironmentObject private var cloudKitManager: CloudKitSharingManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var invitationURL: URL?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingCopiedConfirmation = false
    
    var body: some View {
        List {
            // Introduction
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "person.3.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Invite Family Members")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("Share FamSphere across devices")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Text("Generate an invitation link and share it with family members. Each person can use their own device and Apple ID.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }
            
            // Invitation Link Section
            if let url = invitationURL {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Invitation Link")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                                
                                Text(url.absoluteString)
                                    .font(.caption)
                                    .lineLimit(3)
                                    .foregroundStyle(.blue)
                            }
                            
                            Spacer()
                            
                            Button {
                                copyToClipboard(url.absoluteString)
                            } label: {
                                Image(systemName: showingCopiedConfirmation ? "checkmark" : "doc.on.doc")
                                    .font(.title3)
                                    .foregroundStyle(showingCopiedConfirmation ? .green : .blue)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        ShareLink(item: url) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share via Messages, Email, AirDrop...")
                                Spacer()
                            }
                            .foregroundStyle(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                } header: {
                    Text("Share This Link")
                } footer: {
                    Text("Anyone with this link can join your family's FamSphere. Keep it private!")
                }
            } else {
                Section {
                    Button {
                        Task { await generateInvitation() }
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .padding(.trailing, 8)
                                Text("Generating Invitation...")
                            } else {
                                Image(systemName: "link.badge.plus")
                                    .font(.title3)
                                Text("Generate Invitation Link")
                                    .fontWeight(.medium)
                            }
                            Spacer()
                        }
                    }
                    .disabled(isLoading)
                } footer: {
                    Text("This creates a secure link that family members can use to join your FamSphere family.")
                }
            }
            
            // Error Message
            if let error = errorMessage {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                        
                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }
                }
            }
            
            // Current Participants
            if !cloudKitManager.familyParticipants.isEmpty {
                Section {
                    ForEach(cloudKitManager.familyParticipants, id: \.userIdentity.userRecordID) { participant in
                        ParticipantRow(
                            participant: participant,
                            isOwner: cloudKitManager.isFamilyOwner,
                            onRemove: {
                                Task {
                                    do {
                                        try await cloudKitManager.removeParticipant(participant)
                                    } catch {
                                        errorMessage = error.localizedDescription
                                    }
                                }
                            }
                        )
                    }
                } header: {
                    Text("Family Members (\(cloudKitManager.familyParticipants.count))")
                } footer: {
                    Text("All family members can see and contribute to shared data.")
                }
            }
            
            // How It Works
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    Label("How It Works", systemImage: "info.circle")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    instructionStep(number: 1, text: "Generate an invitation link")
                    instructionStep(number: 2, text: "Share it with family members")
                    instructionStep(number: 3, text: "They open the link on their device")
                    instructionStep(number: 4, text: "They accept the invitation")
                    instructionStep(number: 5, text: "All family data syncs automatically!")
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "lock.shield.fill")
                            .foregroundStyle(.blue)
                        Text("Each family member uses their own Apple ID and device. All data is end-to-end encrypted.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Invite Family")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadInitialData()
        }
    }
    
    // MARK: - Helper Views
    
    private func instructionStep(number: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Actions
    
    private func loadInitialData() async {
        do {
            // Check if we already have a share
            let hasShare = try await cloudKitManager.checkFamilyShareStatus()
            
            if hasShare {
                // Try to generate URL from existing share
                if let share = cloudKitManager.currentFamilyShare {
                    invitationURL = share.url
                }
                
                // Fetch participants
                try await cloudKitManager.fetchParticipants()
            }
        } catch {
            print("Error loading initial data: \(error)")
            errorMessage = error.localizedDescription
        }
    }
    
    private func generateInvitation() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let url = try await cloudKitManager.generateInvitationLink()
            
            await MainActor.run {
                invitationURL = url
                isLoading = false
            }
            
            // Fetch participants after creating share
            try await cloudKitManager.fetchParticipants()
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        
        withAnimation {
            showingCopiedConfirmation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showingCopiedConfirmation = false
            }
        }
    }
}

// MARK: - Participant Row

struct ParticipantRow: View {
    let participant: CKShare.Participant
    let isOwner: Bool
    let onRemove: () -> Void
    
    private var displayName: String {
        if let nameComponents = participant.userIdentity.nameComponents {
            return PersonNameComponentsFormatter().string(from: nameComponents)
        } else {
            return "Family Member"
        }
    }
    
    private var roleText: String {
        if participant.role == .owner {
            return "Owner"
        } else {
            switch participant.permission {
            case .readWrite: return "Member"
            case .readOnly: return "Viewer"
            case .none: return "None"
            case .unknown: return "Unknown"
            @unknown default: return "Unknown"
            }
        }
    }
    
    private var statusText: String {
        switch participant.acceptanceStatus {
        case .accepted: return "Active"
        case .pending: return "Invited"
        case .removed: return "Removed"
        case .unknown: return "Unknown"
        @unknown default: return "Unknown"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: participant.role == .owner ? "crown.fill" : "person.fill")
                .font(.title3)
                .foregroundStyle(participant.role == .owner ? .yellow : .blue)
                .frame(width: 44, height: 44)
                .background(participant.role == .owner ? Color.yellow.opacity(0.2) : Color.blue.opacity(0.2))
                .clipShape(Circle())
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(displayName)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    Text(roleText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("•")
                        .foregroundStyle(.secondary)
                    
                    Text(statusText)
                        .font(.caption)
                        .foregroundStyle(participant.acceptanceStatus == .accepted ? .green : .orange)
                }
            }
            
            Spacer()
            
            // Remove button (only for non-owners if current user is owner)
            if participant.role != .owner && isOwner && participant.acceptanceStatus == .accepted {
                Button(role: .destructive) {
                    onRemove()
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        FamilyInvitationView()
            .environmentObject(CloudKitSharingManager.shared)
    }
}
