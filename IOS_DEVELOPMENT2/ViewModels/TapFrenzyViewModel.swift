import SwiftUI
internal import Combine

@MainActor
final class TapFrenzyViewModel: ObservableObject {
    @Published private(set) var score = 0
    @Published private(set) var timeRemaining = 10
    @Published private(set) var isGameOver = false
    @Published private(set) var multiplier = 1
    @Published private(set) var buttonColor: Color = .blue
    @Published private(set) var highScore: Int

    private var lastTapDate: Date?
    private var gameTimer: Timer?
    private var colorTimer: Timer?

    private let highScoreKey = "tapFrenzyHighScore"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.highScore = userDefaults.integer(forKey: highScoreKey)
    }


    func startGame() {
        score = 0
        timeRemaining = 10
        multiplier = 1
        lastTapDate = nil
        isGameOver = false
        buttonColor = .blue

        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }

        colorTimer?.invalidate()
        colorTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.randomizeColor()
            }
        }
    }

    func stopTimers() {
        gameTimer?.invalidate()
        colorTimer?.invalidate()
    }

    func tapButton() {
        let now = Date()
        if let last = lastTapDate, now.timeIntervalSince(last) <= 0.5 {
            multiplier += 1
        } else {
            multiplier = 1
        }
        lastTapDate = now

        if buttonColor == .green {
            score += 2 * multiplier
        } else if buttonColor == .gray {
            score = max(0, score - 1)
        } else {
            score += 1 * multiplier
        }
    }

    var colorHintMessage: String {
        if buttonColor == .green { return "2x Score Bonus Active!" }
        if buttonColor == .gray { return "Careful! Gray drops your score." }
        return "Tap fast to build your multiplier!"
    }

    private func tick() {
        guard timeRemaining > 0 else {
            endGame()
            return
        }
        timeRemaining -= 1
    }

    private func randomizeColor() {
        let options: [Color] = [.blue, .green, .gray]
        buttonColor = options.randomElement() ?? .blue
    }

    private func endGame() {
        stopTimers()
        isGameOver = true
        if score > highScore {
            highScore = score
            userDefaults.set(highScore, forKey: highScoreKey)
        }
        GameSessionStore.shared.recordSession(mode: .tapFrenzy, score: score)
    }
}
