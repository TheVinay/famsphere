//
//  AppSettings.swift
//  FamSphere
//
//  Created by Vinays Mac on 12/30/25.
//

import Foundation
import SwiftUI

enum AppearanceMode: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

@Observable
final class AppSettings {
    var currentUserName: String {
        didSet {
            UserDefaults.standard.set(currentUserName, forKey: "currentUserName")
        }
    }
    
    var currentUserRole: MemberRole {
        didSet {
            UserDefaults.standard.set(currentUserRole.rawValue, forKey: "currentUserRole")
        }
    }
    
    var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    
    var iMessageSharingEnabled: Bool {
        didSet {
            UserDefaults.standard.set(iMessageSharingEnabled, forKey: "iMessageSharingEnabled")
        }
    }
    
    var isOnboarded: Bool {
        didSet {
            UserDefaults.standard.set(isOnboarded, forKey: "isOnboarded")
        }
    }
    
    var appearanceMode: AppearanceMode {
        didSet {
            UserDefaults.standard.set(appearanceMode.rawValue, forKey: "appearanceMode")
        }
    }
    
    init() {
        self.currentUserName = UserDefaults.standard.string(forKey: "currentUserName") ?? ""
        
        let roleString = UserDefaults.standard.string(forKey: "currentUserRole") ?? "parent"
        self.currentUserRole = MemberRole(rawValue: roleString) ?? .parent
        
        self.notificationsEnabled = UserDefaults.standard.object(forKey: "notificationsEnabled") as? Bool ?? true
        self.iMessageSharingEnabled = UserDefaults.standard.object(forKey: "iMessageSharingEnabled") as? Bool ?? true
        self.isOnboarded = UserDefaults.standard.bool(forKey: "isOnboarded")
        
        let appearanceString = UserDefaults.standard.string(forKey: "appearanceMode") ?? "System"
        self.appearanceMode = AppearanceMode(rawValue: appearanceString) ?? .system
    }
    
    // Helper to calculate total points for a user from goals
    func totalPoints(from goals: [Goal], for userName: String) -> Int {
        goals.filter { $0.createdByChildName == userName }
            .reduce(0) { $0 + $1.totalPointsEarned }
    }
}

