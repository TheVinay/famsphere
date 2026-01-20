//
//  ContentView.swift
//  FamSphere
//
//  Created by Vinays Mac on 12/30/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AppSettings.self) private var appSettings
    
    var body: some View {
        if appSettings.isOnboarded {
            MainTabView()
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
        .environment(AppSettings())
        .modelContainer(for: [FamilyMember.self, ChatMessage.self, CalendarEvent.self, Goal.self])
}
