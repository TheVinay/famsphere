//
//  TestModelInit.swift
//  FamSphere
//
//  Quick test to verify models can initialize
//

import Foundation
import SwiftData

func testModelsInitialize() {
    print("🧪 Testing individual model initialization...")
    
    // Test FamilyMember
    _ = FamilyMember(name: "Test", role: .parent, colorHex: "#FF0000")
    print("✅ FamilyMember initialized")
    
    // Test ChatMessage
    _ = ChatMessage(content: "Test", authorName: "Tester")
    print("✅ ChatMessage initialized")
    
    // Test CalendarEvent
    _ = CalendarEvent(
        title: "Test",
        eventDate: Date(),
        eventType: .personal,
        createdByName: "Tester",
        colorHex: "#FF0000"
    )
    print("✅ CalendarEvent initialized")
    
    // Test Goal
    _ = Goal(title: "Test", createdByChildName: "Child")
    print("✅ Goal initialized")
    
    // Test GoalMilestone
    _ = GoalMilestone(title: "Test", order: 1)
    print("✅ GoalMilestone initialized")
    
    print("🧪 All model tests complete")
}
