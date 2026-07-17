import Foundation
internal import Combine

enum QuizState {
    case selecting
    case loading
    case loaded
    case failed
}

@MainActor
class QuizViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var streak = 0
    @Published var state: QuizState = .selecting
    @Published var answers: [String] = []
    @Published var isRoundOver = false

    @Published var categories: [TriviaCategory] = []
    @Published var categoriesLoadFailed = false
    @Published var selectedCategory: TriviaCategory? = nil
    @Published var selectedDifficulty: Difficulty = .any

    private let service = TriviaService()

    func loadCategories() async {
        categoriesLoadFailed = false
        do {
            categories = try await service.fetchCategories()
        } catch {
            categoriesLoadFailed = true
        }
    }

    func load() async {
        state = .loading
        isRoundOver = false
        currentIndex = 0
        score = 0
        streak = 0
        do {
            questions = try await service.fetchQuestions(
                category: selectedCategory?.id,
                difficulty: selectedDifficulty
            )
            setAnswers()
            state = .loaded
        } catch {
            state = .failed
        }
    }

    func backToSetup() {
        isRoundOver = false
        state = .selecting
    }

    func setAnswers() {
        guard currentIndex < questions.count else { return }
        let question = questions[currentIndex]
        var options = question.incorrect_answers
        options.append(question.correct_answer)
        answers = options.shuffled()
    }

    func submitAnswer(_ answer: String) {
        guard currentIndex < questions.count else { return }
        let question = questions[currentIndex]
        if answer == question.correct_answer {
            streak += 1
            score += 1 + streak
        } else {
            streak = 0
            score = max(0, score - 1)
        }
        if currentIndex < questions.count - 1 {
            currentIndex += 1
            setAnswers()
        } else {
            isRoundOver = true
            GameSessionStore.shared.recordSession(mode: .quizRush, score: score)
        }
    }
}
