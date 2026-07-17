import SwiftUI

enum AppTheme {
    static let backgroundTop = Color(red: 0.08, green: 0.08, blue: 0.11)
    static let backgroundBottom = Color(red: 0.11, green: 0.11, blue: 0.15)
    static let textPrimary = Color(red: 0.96, green: 0.96, blue: 0.97)
    static let textSecondary = Color(red: 0.62, green: 0.62, blue: 0.68)

    static var background: LinearGradient {
        LinearGradient(colors: [backgroundTop, backgroundBottom], startPoint: .top, endPoint: .bottom)
    }
}
