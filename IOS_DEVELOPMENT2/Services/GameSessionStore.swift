import Foundation
internal import Combine
internal import _LocationEssentials

@MainActor
final class GameSessionStore: ObservableObject {
    static let shared = GameSessionStore()

    @Published private(set) var sessions: [GameSession] = []

    private let userDefaults: UserDefaults
    private let storageKey = "gameSessions"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.sessions = Self.load(from: userDefaults, key: storageKey)
    }

    func recordSession(mode: GameMode, score: Int) {
        let coordinate = LocationProvider.shared.lastKnownLocation
        let session = GameSession(
            mode: mode,
            score: score,
            latitude: coordinate?.latitude ?? 0,
            longitude: coordinate?.longitude ?? 0
        )
        sessions.append(session)
        persist()
    }

    func resetAll() {
        sessions.removeAll()
        persist()
    }

    private func persist() {
        do {
            let data = try JSONEncoder().encode(sessions)
            userDefaults.set(data, forKey: storageKey)
        } catch {
            print("Failed to persist game sessions: \(error)")
        }
    }

    private static func load(from userDefaults: UserDefaults, key: String) -> [GameSession] {
        guard let data = userDefaults.data(forKey: key) else { return [] }
        do {
            return try JSONDecoder().decode([GameSession].self, from: data)
        } catch {
            print("Failed to decode game sessions: \(error)")
            return []
        }
    }
}
