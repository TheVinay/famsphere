import SwiftUI

extension GoalStatus {

    var icon: String {
        switch self {
        case .approved:
            return "checkmark.seal.fill"
        case .pending:
            return "clock.badge.exclamationmark"
        case .rejected:
            return "xmark.seal.fill"
        case .completed:
            return "checkmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .approved:
            return .green
        case .pending:
            return .orange
        case .rejected:
            return .red
        case .completed:
            return .blue
        }
    }
}
