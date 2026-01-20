//
//  OnboardingView.swift
//  FamSphere
//
//  Created by Vinays Mac on 12/30/25.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(AppSettings.self) private var appSettings
    @Environment(\.modelContext) private var modelContext
    
    @State private var userName: String = ""
    @State private var selectedRole: MemberRole = .parent
    
    var body: some View {
        @Bindable var settings = appSettings
        
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                
                // App Icon/Logo Area
                Image(systemName: "circle.hexagongrid.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.bottom, 10)
                
                VStack(spacing: 8) {
                    Text("Welcome to FamSphere")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("A shared space for your family\nto chat, plan, and grow together")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // Family sharing info
                    if selectedRole == .parent {
                        Text("💡 Tip: Add family members in Settings after setup")
                            .font(.caption)
                            .foregroundStyle(.blue)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                }
                .padding(.bottom, 20)
                
                // User Setup
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Name")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        TextField("Enter your name", text: $userName)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.name)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Role")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Picker("Role", selection: $selectedRole) {
                            Text("Parent").tag(MemberRole.parent)
                            Text("Child").tag(MemberRole.child)
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Get Started Button
                Button(action: completeOnboarding) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color.gray
                            : Color.blue
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func completeOnboarding() {
        let trimmedName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        appSettings.currentUserName = trimmedName
        appSettings.currentUserRole = selectedRole
        
        // Create the user's family member record
        let member = FamilyMember(
            name: trimmedName,
            role: selectedRole,
            colorHex: selectedRole == .parent ? "#4A90E2" : "#F5A623"
        )
        modelContext.insert(member)
        
        // Mark onboarding complete
        appSettings.isOnboarded = true
    }
}

#Preview {
    OnboardingView()
        .environment(AppSettings())
        .modelContainer(for: [FamilyMember.self, ChatMessage.self, CalendarEvent.self, Goal.self])
}
