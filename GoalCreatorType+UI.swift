import SwiftUI

extension GoalCreatorType {
    var icon: String {
        switch self {
        case .parent:
            return "person.fill"
        case .child:
            return "figure.and.child.holdinghands"
        case .childSuggested:
            return "lightbulb.fill"
        }
    }
    
    var badge: String {
        switch self {
        case .parent:
            return "Parent Goal"
        case .child:
            return "My Goal"
        case .childSuggested:
            return "Pending Approval"
        }
    }

    var color: Color {
        switch self {
        case .parent:
            return .blue
        case .child:
            return .green
        case .childSuggested:
            return .orange
        }
    }
}
