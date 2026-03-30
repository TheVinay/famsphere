//
//  EventType+UI.swift
//  FamSphere
//

import SwiftUI

extension EventType {
    var icon: String {
        switch self {
        case .school:
            return "book.fill"
        case .sports:
            return "figure.run"
        case .family:
            return "house.fill"
        case .personal:
            return "person.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .school:
            return .blue
        case .sports:
            return .green
        case .family:
            return .orange
        case .personal:
            return .purple
        }
    }
}
