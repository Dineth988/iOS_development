import Foundation
internal import Combine

@MainActor
final class LightItUpViewModel: ObservableObject {
    @Published private(set) var cards: [Card] = []
    @Published private(set) var score = 0
    @Published private(set) var timeRemaining = 60
    @Published private(set) var isGameOver = false
    @Published private(set) var currentLevel: Level = .l1
    @Published private(set) var highScore: Int

    private var roundTimer: Timer?
    private var lightTimer: Timer?
    private let highScoreKey = "lightItUpHighScore"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.highScore = userDefaults.integer(forKey: highScoreKey)
    }


    func startGame() {
        score = 0
        timeRemaining = 60
        isGameOver = false
        currentLevel = .l1
        setupCards(for: currentLevel)

        roundTimer?.invalidate()
        roundTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }

        startLightTimer()
    }

    func stopTimers() {
        roundTimer?.invalidate()
        lightTimer?.invalidate()
    }


    func tapCard(_ card: Card) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        if cards[index].isLit {
            score += 1
            cards[index].isLit = false
        } else {
            score = max(0, score - 1)
        }
    }


    private func tick() {
        guard timeRemaining > 0 else {
            endGame()
            return
        }
        timeRemaining -= 1
        let elapsed = 60 - timeRemaining
        let newLevel = Level.forElapsed(elapsed)
        if newLevel != currentLevel {
            currentLevel = newLevel
            setupCards(for: currentLevel)
            startLightTimer()
        }
    }

    private func setupCards(for level: Level) {
        cards = (0..<level.gridSize).map { Card(id: $0) }
    }

    private func startLightTimer() {
        lightTimer?.invalidate()
        lightTimer = Timer.scheduledTimer(withTimeInterval: currentLevel.litWindow, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.relightCards()
            }
        }
    }

    private func relightCards() {
        if cards.contains(where: { $0.isLit }) {
            score = max(0, score - 1)
        }
        for i in cards.indices {
            cards[i].isLit = false
        }
        let indices = Array(cards.indices).shuffled().prefix(currentLevel.litCount)
        for i in indices {
            cards[i].isLit = true
        }
    }

    private func endGame() {
        stopTimers()
        isGameOver = true
        if score > highScore {
            highScore = score
            userDefaults.set(highScore, forKey: highScoreKey)
        }
        GameSessionStore.shared.recordSession(mode: .lightItUp, score: score)
    }
}
