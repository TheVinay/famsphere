//
//  FamSphereApp.swift
//  FamSphere
//
//  Created by Vinays Mac on 12/30/25.
//

import SwiftUI
import SwiftData
import CloudKit

@main
struct FamSphereApp: App {
    var modelContainer: ModelContainer
    @State private var appSettings = AppSettings()
    @StateObject private var cloudKitManager: CloudKitSharingManager

    init() {
        // Safe StateObject init for singleton
        _cloudKitManager = StateObject(wrappedValue: CloudKitSharingManager.shared)

        print("🔵 Starting ModelContainer initialization...")
        
        // Test that models can initialize
        testModelsInitialize()

        let schema = Schema([
            FamilyMember.self,
            ChatMessage.self,
            CalendarEvent.self,
            Goal.self,
            GoalMilestone.self
        ])

        let containerIdentifier = "iCloud.VinPersonal.FamSphere"
        
        // FORCE FRESH START: Delete existing database files
        #if DEBUG
        print("🗑️ DEBUG MODE: Attempting to delete existing database...")
        Self.deleteExistingDatabase()
        #endif

        // 1) Try CloudKit private
        do {
            print("🔵 Attempting CloudKit Private Database initialization...")

            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true,
                cloudKitDatabase: .private(containerIdentifier)
            )

            self.modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )

            print("✅ ModelContainer initialized with CloudKit Private Database")
            print("   Container: \(containerIdentifier)")
            return

        } catch {
            print("⚠️ CloudKit initialization failed: \(error)")
            if let nsError = error as NSError? {
                print("⚠️ Error domain: \(nsError.domain)")
                print("⚠️ Error code: \(nsError.code)")
                print("⚠️ User info: \(nsError.userInfo)")
            }
        }

        // 2) Try local-only
        do {
            print("🔵 Attempting local-only storage...")

            let localConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true,
                cloudKitDatabase: .none
            )

            self.modelContainer = try ModelContainer(
                for: schema,
                configurations: [localConfiguration]
            )

            print("⚠️ Using local-only storage (no cloud sync)")
            return

        } catch {
            print("⚠️ Local storage failed: \(error)")
            print("⚠️ This might be a schema migration issue. Trying lightweight migration...")
        }

        // 3) In-memory fallback (never crash with try!)
        do {
            print("🔵 Attempting in-memory fallback...")

            let memoryConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )

            self.modelContainer = try ModelContainer(
                for: schema,
                configurations: [memoryConfiguration]
            )

            print("⚠️ Using in-memory storage (data will NOT persist between launches)")
            print("⚠️ SOLUTION: Delete the app and reinstall to fix schema migration issues")
        } catch {
            // Absolute last resort: still do not crash with try!
            // If even this fails, something is seriously wrong with the schema/model types.
            print("❌ CRITICAL: In-memory container failed: \(error)")

            // Create an empty container with the same schema attempt again
            // If this fails too, we hard fail with a clear message.
            fatalError("FamSphere failed to initialize SwiftData ModelContainer. Please delete the app and reinstall. Error: \(error)")
        }
    }
    
    // MARK: - Database Cleanup
    
    private static func deleteExistingDatabase() {
        let fileManager = FileManager.default
        
        // Get the application support directory
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            print("⚠️ Could not locate Application Support directory")
            return
        }
        
        print("📂 App Support Directory: \(appSupportURL.path)")
        
        // SwiftData stores files in Application Support
        // Look for .store, .store-shm, .store-wal files
        do {
            let contents = try fileManager.contentsOfDirectory(at: appSupportURL, includingPropertiesForKeys: nil)
            
            var deletedCount = 0
            for fileURL in contents {
                let filename = fileURL.lastPathComponent
                
                // Delete SwiftData store files
                if filename.hasSuffix(".store") || 
                   filename.hasSuffix(".store-shm") || 
                   filename.hasSuffix(".store-wal") ||
                   filename.contains("default.store") {
                    
                    do {
                        try fileManager.removeItem(at: fileURL)
                        print("🗑️ Deleted: \(filename)")
                        deletedCount += 1
                    } catch {
                        print("⚠️ Could not delete \(filename): \(error)")
                    }
                }
            }
            
            if deletedCount > 0 {
                print("✅ Deleted \(deletedCount) database file(s)")
            } else {
                print("ℹ️ No existing database files found")
            }
            
        } catch {
            print("⚠️ Error scanning Application Support: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            if appSettings.isOnboarded {
                MainTabView()
                    .environment(appSettings)
                    .environmentObject(cloudKitManager)
            } else {
                OnboardingView()
                    .environment(appSettings)
                    .environmentObject(cloudKitManager)
            }
        }
        .modelContainer(modelContainer)
    }
}
