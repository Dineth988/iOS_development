import Foundation
internal import UIKit

struct TriviaService {
    func fetchCategories() async throws -> [TriviaCategory] {
        let url = URL(string: "https://opentdb.com/api_category.php")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(CategoryResponse.self, from: data)
        return decoded.trivia_categories.sorted { $0.name < $1.name }
    }

    func fetchQuestions(category: Int?, difficulty: Difficulty) async throws -> [Question] {
        var components = URLComponents(string: "https://opentdb.com/api.php")!
        var items = [
            URLQueryItem(name: "amount", value: "10"),
            URLQueryItem(name: "type", value: "multiple")
        ]
        if let category {
            items.append(URLQueryItem(name: "category", value: "\(category)"))
        }
        if difficulty != .any {
            items.append(URLQueryItem(name: "difficulty", value: difficulty.rawValue))
        }
        components.queryItems = items

        let (data, _) = try await URLSession.shared.data(from: components.url!)
        let decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
        return decoded.results.map(Self.decodedHTML)
    }

    private static func decodedHTML(_ question: Question) -> Question {
        Question(
            question: question.question.htmlDecoded,
            correct_answer: question.correct_answer.htmlDecoded,
            incorrect_answers: question.incorrect_answers.map { $0.htmlDecoded }
        )
    }
}

private extension String {
    var htmlDecoded: String {
        guard let data = self.data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        return (try? NSAttributedString(data: data, options: options, documentAttributes: nil).string) ?? self
    }
}
