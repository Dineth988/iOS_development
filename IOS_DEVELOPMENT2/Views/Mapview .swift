import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var selectedSession: GameSession?

    var body: some View {
        NavigationStack {
            Map(position: $viewModel.cameraPosition) {
                UserAnnotation()

                ForEach(viewModel.pinnedSessions) { session in
                    Annotation(session.mode.displayName, coordinate: session.coordinate) {
                        Button {
                            selectedSession = session
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(session.mode.accentColor)
                                    .frame(width: 30, height: 30)
                                Image(systemName: session.mode.icon)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                        }
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                LocationProvider.shared.requestPermissionIfNeeded()
            }
            .sheet(item: $selectedSession) { session in
                SessionDetailSheet(session: session)
            }
        }
    }
}

// MARK: - Tapped-pin detail

private struct SessionDetailSheet: View {
    let session: GameSession
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(session.mode.accentColor.opacity(0.18))
                        .frame(width: 72, height: 72)
                    Image(systemName: session.mode.icon)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(session.mode.accentColor)
                }
                .padding(.top, 12)

                Text(session.mode.displayName)
                    .font(.system(.title2, design: .rounded))
                    .bold()

                Text("Score: \(session.score)")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text(session.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
            .navigationTitle("Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .presentationDetents([.height(300)])
    }
}

#Preview {
    MapView()
}
