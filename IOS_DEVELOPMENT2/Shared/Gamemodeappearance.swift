import SwiftUI

extension GameMode {
    var icon: String {
        switch self {
        case .tapFrenzy: return "hand.tap.fill"
        case .lightItUp: return "square.grid.3x3.fill.square"
        case .quizRush: return "bolt.horizontal.circle.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .tapFrenzy: return Color(red: 1.0, green: 0.42, blue: 0.29)
        case .lightItUp: return Color(red: 0.16, green: 0.83, blue: 0.65)
        case .quizRush: return Color(red: 0.42, green: 0.32, blue: 0.78)
        }
    }
}
