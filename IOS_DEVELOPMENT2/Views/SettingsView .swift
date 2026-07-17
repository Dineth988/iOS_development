import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var viewModel: SettingsViewModel
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Daily Challenge Reminder", isOn: $viewModel.notificationsEnabled)

                    if viewModel.notificationsEnabled {
                        DatePicker(
                            "Challenge Time",
                            selection: $viewModel.challengeTime,
                            displayedComponents: .hourAndMinute
                        )
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("You'll see a reminder in-app at this time, as long as Mini Games is open — this doesn't use push notifications.")
                }

                Section {
                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        Text("Reset All Stats")
                    }
                } footer: {
                    Text("Clears every game's high score. This can't be undone.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog(
                "Reset all stats?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset All Stats", role: .destructive) {
                    viewModel.resetAllStats()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently clears every game's high score. This can't be undone.")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
}
