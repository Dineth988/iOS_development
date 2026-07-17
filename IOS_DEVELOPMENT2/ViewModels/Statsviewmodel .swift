import Foundation
internal import Combine

@MainActor
final class StatsViewModel: ObservableObject {
    @Published private(set) var sessions: [GameSession] = []

    private var cancellable: AnyCancellable?

    init(store: GameSessionStore = .shared) {
        self.sessions = store.sessions
        cancellable = store.$sessions.sink { [weak self] sessions in
            self?.sessions = sessions
        }
    }

    var totalGamesPlayed: Int {
        sessions.count
    }

    var totalScore: Int {
        sessions.reduce(0) { $0 + $1.score }
    }

    func personalBest(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.map(\.score).max() ?? 0
    }

    var recentSessions: [GameSession] {
        Array(sessions.sorted { $0.timestamp > $1.timestamp }.prefix(10))
    }

    struct ModeTotal: Identifiable {
        var id: GameMode { mode }
        let mode: GameMode
        let totalScore: Int
    }

    var totalsByMode: [ModeTotal] {
        GameMode.allCases.map { mode in
            let total = sessions.filter { $0.mode == mode }.reduce(0) { $0 + $1.score }
            return ModeTotal(mode: mode, totalScore: total)
        }
    }
}
