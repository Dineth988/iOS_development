import Foundation
import _MapKit_SwiftUI
import MapKit
internal import Combine

@MainActor
final class MapViewModel: ObservableObject {
    @Published private(set) var sessions: [GameSession] = []
    @Published var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)

    private var cancellable: AnyCancellable?

    init(store: GameSessionStore = .shared) {
        self.sessions = store.sessions
        cancellable = store.$sessions.sink { [weak self] sessions in
            self?.sessions = sessions
        }
    }

    var pinnedSessions: [GameSession] {
        sessions.filter { $0.latitude != 0 || $0.longitude != 0 }
    }
}

extension GameSession {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
