import Foundation

enum GameMode: String, Codable, CaseIterable {
    case tapFrenzy
    case lightItUp
    case quizRush

    var displayName: String {
        switch self {
        case .tapFrenzy: return "Tap Frenzy"
        case .lightItUp: return "Light It Up"
        case .quizRush: return "Quiz Rush"
        }
    }
}

struct GameSession: Identifiable, Codable, Equatable {
    let id: UUID
    let mode: GameMode
    let score: Int
    let timestamp: Date
    let latitude: Double
    let longitude: Double

    init(
        id: UUID = UUID(),
        mode: GameMode,
        score: Int,
        timestamp: Date = Date(),
        latitude: Double,
        longitude: Double
    ) {
        self.id = id
        self.mode = mode
        self.score = score
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
    }
}
