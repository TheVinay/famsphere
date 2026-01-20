//
//  MainTabView.swift
//  FamSphere
//
//  Created by Vinays Mac on 12/30/25.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(AppSettings.self) private var appSettings
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                .tag(0)
            
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .tag(1)
            
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(2)
            
            GoalsView()
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .tint(.blue) // Use system blue color instead of custom AccentColor
        .preferredColorScheme(appSettings.appearanceMode.colorScheme)
    }
}

#Preview {
    MainTabView()
        .environment(AppSettings())
        .modelContainer(for: [FamilyMember.self, ChatMessage.self, CalendarEvent.self, Goal.self])
}
