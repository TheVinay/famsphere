//
//  CloudKitSharingManager.swift
//  FamSphere
//

import Foundation
import CloudKit
import SwiftUI
import Combine

@MainActor
final class CloudKitSharingManager: ObservableObject {

    static let shared = CloudKitSharingManager()

    @Published var isSharing = false
    @Published var sharingError: Error?
    @Published var currentFamilyShare: CKShare?
    @Published var familyParticipants: [CKShare.Participant] = []
    @Published var isFamilyOwner = false

    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private let sharedDatabase: CKDatabase

    private static let containerIdentifier = "iCloud.VinPersonal.FamSphere"

    private init() {
        self.container = CKContainer(identifier: Self.containerIdentifier)
        self.privateDatabase = container.privateCloudDatabase
        self.sharedDatabase = container.sharedCloudDatabase
    }

    // MARK: - Account

    func checkAccountStatus() async throws -> CKAccountStatus {
        try await container.accountStatus()
    }

    // MARK: - Share Discovery

    /// Checks whether the user already has access to a family share
    func checkFamilyShareStatus() async throws -> Bool {
        let query = CKQuery(
            recordType: "FamilyZone",
            predicate: NSPredicate(value: true)
        )

        let (results, _) = try await sharedDatabase.records(matching: query)

        for (_, result) in results {
            guard case .success(let record) = result else { continue }

            if let share = try await fetchShare(for: record) {
                currentFamilyShare = share
                let myID = try? await container.userRecordID()
                isFamilyOwner = (share.owner.userIdentity.userRecordID == myID)
                return true
            }
        }

        return false
    }

    // MARK: - Share Creation

    func createFamilyShare() async throws -> CKShare {
        let zoneID = CKRecordZone.ID(zoneName: "FamilyZone")

        // Ensure zone exists
        _ = try await privateDatabase.save(CKRecordZone(zoneID: zoneID))

        let recordID = CKRecord.ID(
            recordName: "FamilyRoot",
            zoneID: zoneID
        )

        let rootRecord = CKRecord(
            recordType: "FamilyZone",
            recordID: recordID
        )

        rootRecord["name"] = "Family Data" as CKRecordValue
        rootRecord["createdDate"] = Date() as CKRecordValue

        let share = CKShare(rootRecord: rootRecord)
        share[CKShare.SystemFieldKey.title] = "FamSphere Family" as CKRecordValue
        share.publicPermission = .none

        let savedShare = try await save(root: rootRecord, share: share)

        currentFamilyShare = savedShare
        isFamilyOwner = true

        return savedShare
    }

    private func save(root: CKRecord, share: CKShare) async throws -> CKShare {
        let (savedRecords, _) = try await privateDatabase.modifyRecords(
            saving: [root, share],
            deleting: []
        )

        // modifyRecords returns a Dictionary<CKRecord.ID, Result<CKRecord, Error>>
        // Find the saved share by checking the values
        for (_, result) in savedRecords {
            if case .success(let record) = result,
               let savedShare = record as? CKShare {
                return savedShare
            }
        }
        
        throw FamSphereCloudKitError.notShared
    }

    // MARK: - Share Fetching

    private func fetchShare(for record: CKRecord) async throws -> CKShare? {
        guard let ref = record.share else { return nil }
        let fetched = try await sharedDatabase.record(for: ref.recordID)
        return fetched as? CKShare
    }

    // MARK: - Invitations

    func generateInvitationLink() async throws -> URL {
        let share: CKShare

        if let existing = currentFamilyShare {
            share = existing
        } else {
            share = try await createFamilyShare()
        }

        guard let url = share.url else {
            throw FamSphereCloudKitError.noShareURL
        }

        return url
    }

    func acceptShare(metadata: CKShare.Metadata) async throws {
        let accepted = try await container.accept(metadata)
        currentFamilyShare = accepted
        isFamilyOwner = false
        try await fetchParticipants()
    }

    // MARK: - Participants

    func fetchParticipants() async throws {
        guard let share = currentFamilyShare else { return }

        let fetched = try await sharedDatabase.record(for: share.recordID)
        guard let fetchedShare = fetched as? CKShare else {
            throw FamSphereCloudKitError.notShared
        }

        currentFamilyShare = fetchedShare
        familyParticipants = fetchedShare.participants
    }

    func removeParticipant(_ participant: CKShare.Participant) async throws {
        guard isFamilyOwner, let share = currentFamilyShare else {
            throw FamSphereCloudKitError.permissionDenied
        }

        share.removeParticipant(participant)
        _ = try await privateDatabase.save(share)
        try await fetchParticipants()
    }

    // MARK: - Exit / Delete

    func leaveFamily() {
        currentFamilyShare = nil
        familyParticipants = []
        isFamilyOwner = false
    }

    func deleteFamily() async throws {
        guard isFamilyOwner, let share = currentFamilyShare else {
            throw FamSphereCloudKitError.permissionDenied
        }

        _ = try await privateDatabase.deleteRecord(withID: share.recordID)
        leaveFamily()
    }
}

// MARK: - Errors

enum FamSphereCloudKitError: LocalizedError {
    case noShareURL
    case notShared
    case permissionDenied
    case notSignedIn

    var errorDescription: String? {
        switch self {
        case .noShareURL:
            return "Could not generate a share link."
        case .notShared:
            return "Family sharing is not configured."
        case .permissionDenied:
            return "You do not have permission to perform this action."
        case .notSignedIn:
            return "Please sign in to iCloud."
        }
    }
}
