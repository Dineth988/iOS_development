import SwiftUI

struct LightItUpView: View {
    @StateObject private var viewModel = LightItUpViewModel()

    private let mode = GameMode.lightItUp

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            VStack(spacing: 20) {
                header

                if viewModel.isGameOver {
                    Spacer()
                    gameOverCard
                        .transition(.scale.combined(with: .opacity))
                    Spacer()
                } else {
                    grid
                }
            }
            .padding()
            .animation(.default, value: viewModel.isGameOver)
        }
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear {
            viewModel.startGame()
        }
        .onDisappear {
            viewModel.stopTimers()
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            statBadge(label: "SCORE", value: "\(viewModel.score)")
            statBadge(label: "TIME", value: "\(viewModel.timeRemaining)s")
        }
    }

    private func statBadge(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(.title2, design: .rounded))
                .bold()
                .foregroundColor(AppTheme.textPrimary)
            Text(label)
                .font(.caption2)
                .fontWeight(.semibold)
                .tracking(0.5)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }


    private var grid: some View {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible()),
                count: viewModel.currentLevel.columns
            ),
            spacing: 10
        ) {
            ForEach(viewModel.cards) { card in
                RoundedRectangle(cornerRadius: 12)
                    .fill(card.isLit ? mode.accentColor : Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(card.isLit ? mode.accentColor : Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: card.isLit ? mode.accentColor.opacity(0.5) : .clear, radius: 8)
                    .scaleEffect(card.isLit ? 1.03 : 1.0)
                    .frame(height: 80)
                    .animation(.easeOut(duration: 0.15), value: card.isLit)
                    .onTapGesture {
                        viewModel.tapCard(card)
                    }
            }
        }
    }


    private var gameOverCard: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(mode.accentColor.opacity(0.15))
                    .frame(width: 84, height: 84)
                Image(systemName: mode.icon)
                    .font(.system(size: 32))
                    .foregroundColor(mode.accentColor)
            }

            Text("Game Over")
                .font(.system(.title2, design: .rounded))
                .bold()
                .foregroundColor(AppTheme.textPrimary)

            HStack(spacing: 28) {
                resultStat(label: "FINAL SCORE", value: "\(viewModel.score)")
                Divider()
                    .frame(height: 32)
                    .background(Color.white.opacity(0.1))
                resultStat(label: "HIGH SCORE", value: "\(viewModel.highScore)")
            }

            Button {
                viewModel.startGame()
            } label: {
                Text("Play Again")
                    .font(.system(.headline, design: .rounded))
                    .frame(maxWidth: 220)
            }
            .buttonStyle(.borderedProminent)
            .tint(mode.accentColor)
            .controlSize(.large)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    private func resultStat(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.title2, design: .rounded))
                .bold()
                .foregroundColor(AppTheme.textPrimary)
            Text(label)
                .font(.caption2)
                .fontWeight(.semibold)
                .tracking(0.5)
                .foregroundColor(AppTheme.textSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        LightItUpView()
    }
}
