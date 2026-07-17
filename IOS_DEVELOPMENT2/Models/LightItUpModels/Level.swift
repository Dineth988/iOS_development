import Foundation

enum Level: Equatable {
    case l1, l2, l3, l4

    var gridSize: Int {
        switch self {
        case .l1: return 3
        case .l2: return 4
        case .l3: return 6
        case .l4: return 9
        }
    }

    var columns: Int {
        switch self {
        case .l1: return 3
        case .l2: return 4
        case .l3: return 3
        case .l4: return 3
        }
    }

    var litWindow: Double {
        switch self {
        case .l1: return 1.5
        case .l2: return 1.2
        case .l3: return 1.0
        case .l4: return 0.8
        }
    }

    var litCount: Int {
        self == .l4 ? 2 : 1
    }

    static func forElapsed(_ elapsed: Int) -> Level {
        switch elapsed {
        case 0..<15: return .l1
        case 15..<30: return .l2
        case 30..<45: return .l3
        default: return .l4
        }
    }
}
