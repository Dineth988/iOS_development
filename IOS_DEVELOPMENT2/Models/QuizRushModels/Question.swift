import Foundation

struct TriviaResponse: Codable {
    let results: [Question]
}

struct Question: Codable, Identifiable {
    var id: String { question }
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}

struct TriviaCategory: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
}

struct CategoryResponse: Codable {
    let trivia_categories: [TriviaCategory]
}

enum Difficulty: String, CaseIterable, Identifiable {
    case any = ""
    case easy
    case medium
    case hard

    var id: String { rawValue }

    var label: String {
        switch self {
        case .any: return "Any"
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
}
