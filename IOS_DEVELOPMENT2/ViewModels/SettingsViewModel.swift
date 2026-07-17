import Foundation
import SwiftUI
internal import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var notificationsEnabled: Bool {
        didSet { userDefaults.set(notificationsEnabled, forKey: Keys.enabled) }
    }

    @Published var challengeTime: Date {
        didSet { persistChallengeTime() }
    }

    @Published var isShowingChallengeBanner = false

    private let userDefaults: UserDefaults
    private var monitorTimer: Timer?
    private var lastFiredDayKey: String?

    private enum Keys {
        static let enabled = "settings.notificationsEnabled"
        static let hour = "settings.dailyChallengeHour"
        static let minute = "settings.dailyChallengeMinute"
        static let lastFiredDay = "settings.dailyChallengeLastFiredDay"
    }

    private let highScoreKeys = ["tapFrenzyHighScore", "lightItUpHighScore"]

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.notificationsEnabled = userDefaults.object(forKey: Keys.enabled) as? Bool ?? false

        let hour = userDefaults.object(forKey: Keys.hour) as? Int ?? 18
        let minute = userDefaults.object(forKey: Keys.minute) as? Int ?? 0
        self.challengeTime = Self.makeTime(hour: hour, minute: minute)

        self.lastFiredDayKey = userDefaults.string(forKey: Keys.lastFiredDay)
    }

    func startMonitoring() {
        monitorTimer?.invalidate()
        checkNow()
        monitorTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.checkNow() }
        }
    }

    func stopMonitoring() {
        monitorTimer?.invalidate()
    }

    func resetAllStats() {
        for key in highScoreKeys {
            userDefaults.removeObject(forKey: key)
        }
        GameSessionStore.shared.resetAll()
    }

    private func checkNow() {
        guard notificationsEnabled else { return }

        let now = Date()
        let todayKey = Self.dayKey(for: now)
        guard lastFiredDayKey != todayKey else { return } // already fired today

        let calendar = Calendar.current
        let nowComps = calendar.dateComponents([.hour, .minute], from: now)
        let targetComps = calendar.dateComponents([.hour, .minute], from: challengeTime)

        if nowComps.hour == targetComps.hour, nowComps.minute == targetComps.minute {
            isShowingChallengeBanner = true
            lastFiredDayKey = todayKey
            userDefaults.set(todayKey, forKey: Keys.lastFiredDay)
        }
    }

    private func persistChallengeTime() {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: challengeTime)
        userDefaults.set(comps.hour, forKey: Keys.hour)
        userDefaults.set(comps.minute, forKey: Keys.minute)
    }

    private static func makeTime(hour: Int, minute: Int) -> Date {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = hour
        comps.minute = minute
        return Calendar.current.date(from: comps) ?? Date()
    }

    private static func dayKey(for date: Date) -> String {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return "\(comps.year ?? 0)-\(comps.month ?? 0)-\(comps.day ?? 0)"
    }
}
