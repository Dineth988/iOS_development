import SwiftUI

private enum FrenzyTheme {
    static let backgroundTop = Color(red: 0.10, green: 0.07, blue: 0.12)
    static let backgroundBottom = Color(red: 0.16, green: 0.08, blue: 0.09)
    static let surface = Color.white.opacity(0.06)
    static let surfaceStroke = Color.white.opacity(0.10)
    static let textPrimary = Color(red: 0.97, green: 0.95, blue: 0.94)
    static let textSecondary = Color(red: 0.72, green: 0.63, blue: 0.62)
    static let ember = Color(red: 1.0, green: 0.42, blue: 0.29)
}

struct TapFrenzyView: View {
    @StateObject private var viewModel = TapFrenzyViewModel()

    @State private var isPressed = false
    @State private var deltaText: String?
    @State private var deltaTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [FrenzyTheme.backgroundTop, FrenzyTheme.backgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 25) {
                scoreBoard
                timeBadge

                Spacer()

                if viewModel.isGameOver {
                    gameOverCard
                        .transition(.scale.combined(with: .opacity))
                } else {
                    tapArea
                }

                Spacer()
            }
            .padding()
        }
        .animation(.default, value: viewModel.isGameOver)
        .navigationTitle("Tap Frenzy")
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


    private var scoreBoard: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("SCORE")
                    .font(.caption)
                    .bold()
                    .tracking(0.5)
                    .foregroundColor(FrenzyTheme.textSecondary)
                Text("\(viewModel.score)")
                    .font(.system(.title, design: .rounded))
                    .bold()
                    .foregroundColor(FrenzyTheme.textPrimary)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: viewModel.score)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: 4) {
                Text("BEST")
                    .font(.caption)
                    .bold()
                    .tracking(0.5)
                    .foregroundColor(FrenzyTheme.textSecondary)
                Text("\(viewModel.highScore)")
                    .font(.system(.title2, design: .rounded))
                    .foregroundColor(FrenzyTheme.textSecondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(FrenzyTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(FrenzyTheme.surfaceStroke, lineWidth: 1)
                )
        )
    }

    private var timeBadge: some View {
        let isUrgent = viewModel.timeRemaining <= 3
        return HStack {
            Image(systemName: "timer")
                .foregroundColor(isUrgent ? FrenzyTheme.ember : FrenzyTheme.textPrimary)
            Text("Time Remaining: \(viewModel.timeRemaining)s")
                .font(.system(.headline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(isUrgent ? FrenzyTheme.ember : FrenzyTheme.textPrimary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(isUrgent ? FrenzyTheme.ember.opacity(0.12) : FrenzyTheme.surface)
        .cornerRadius(20)
        .animation(.default, value: viewModel.timeRemaining)
    }


    private var gameOverCard: some View {
        VStack(spacing: 20) {
            Image(systemName: "crown.fill")
                .font(.system(size: 50))
                .foregroundColor(FrenzyTheme.ember)

            Text("Game Over")
                .font(.system(.title, design: .rounded))
                .bold()
                .foregroundColor(FrenzyTheme.textPrimary)

            Text("Final Score: \(viewModel.score)")
                .font(.headline)
                .foregroundColor(FrenzyTheme.textSecondary)

            Button(action: viewModel.startGame) {
                Text("Play Again")
                    .font(.headline)
                    .frame(maxWidth: 200)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(FrenzyTheme.ember)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(FrenzyTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(FrenzyTheme.surfaceStroke, lineWidth: 1)
                )
        )
    }

    private var tapArea: some View {
        VStack(spacing: 16) {
            multiplierBadge

            ZStack {
                countdownRing

                Button(action: handleTap) {
                    ZStack(alignment: .topTrailing) {
                        Circle()
                            .fill(buttonGradient)
                            .frame(width: 160, height: 160)
                            .shadow(
                                color: buttonGlow.opacity(0.5),
                                radius: isPressed ? 6 : 16,
                                x: 0, y: isPressed ? 3 : 8
                            )
                            .overlay(
                                Text("TAP")
                                    .font(.system(.largeTitle, design: .rounded))
                                    .bold()
                                    .foregroundColor(.white)
                            )

                        Image(systemName: stateIcon)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Circle().fill(Color.black.opacity(0.25)))
                            .offset(x: -6, y: 6)
                    }
                    .scaleEffect(isPressed ? 0.92 : 1.0)
                }
                .disabled(viewModel.timeRemaining == 0)

                if let deltaText {
                    Text(deltaText)
                        .font(.system(.title3, design: .rounded))
                        .bold()
                        .foregroundColor(deltaText.hasPrefix("-") ? FrenzyTheme.ember : FrenzyTheme.textPrimary)
                        .offset(y: -110)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .offset(y: 8)),
                            removal: .opacity.combined(with: .offset(y: -14))
                        ))
                }
            }
            .frame(height: 200)

            Text(viewModel.colorHintMessage)
                .font(.caption)
                .foregroundColor(FrenzyTheme.textSecondary)
                .frame(height: 20)
        }
    }

    private var multiplierBadge: some View {
        HStack(spacing: 6) {
            if viewModel.multiplier > 1 {
                Image(systemName: "flame.fill")
                    .font(.caption)
            }
            Text("x\(viewModel.multiplier)")
                .font(.system(.title2, design: .rounded))
                .bold()
        }
        .foregroundColor(.white)
        .padding(.vertical, 6)
        .padding(.horizontal, 16)
        .background(viewModel.multiplier > 1 ? FrenzyTheme.ember : Color.white.opacity(0.15))
        .clipShape(Capsule())
        .scaleEffect(viewModel.multiplier > 1 ? 1.1 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.5), value: viewModel.multiplier)
    }

    private var countdownRing: some View {
        let progress = Double(viewModel.timeRemaining) / 10.0
        let isUrgent = viewModel.timeRemaining <= 3
        return Circle()
            .trim(from: 0, to: max(progress, 0))
            .stroke(
                isUrgent ? FrenzyTheme.ember : FrenzyTheme.textSecondary.opacity(0.6),
                style: StrokeStyle(lineWidth: 5, lineCap: .round)
            )
            .frame(width: 184, height: 184)
            .rotationEffect(.degrees(-90))
            .animation(.linear(duration: 1), value: viewModel.timeRemaining)
    }


    private var buttonGradient: LinearGradient {
        let colors: [Color]
        switch viewModel.buttonColor {
        case .green:
            colors = [Color(red: 0.20, green: 0.83, blue: 0.60), Color(red: 0.02, green: 0.55, blue: 0.40)]
        case .gray:
            colors = [Color(red: 0.55, green: 0.55, blue: 0.58), Color(red: 0.30, green: 0.30, blue: 0.33)]
        default:
            colors = [Color(red: 0.38, green: 0.56, blue: 1.0), Color(red: 0.16, green: 0.32, blue: 0.85)]
        }
        return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
    }

    private var buttonGlow: Color {
        switch viewModel.buttonColor {
        case .green: return Color(red: 0.20, green: 0.83, blue: 0.60)
        case .gray: return Color(red: 0.55, green: 0.55, blue: 0.58)
        default: return Color(red: 0.38, green: 0.56, blue: 1.0)
        }
    }

    private var stateIcon: String {
        switch viewModel.buttonColor {
        case .green: return "bolt.fill"
        case .gray: return "exclamationmark.triangle.fill"
        default: return "hand.tap.fill"
        }
    }

    private func handleTap() {
        withAnimation(.snappy(duration: 0.1)) {
            isPressed = true
        }

        let before = viewModel.score
        viewModel.tapButton()
        let delta = viewModel.score - before
        showDelta(delta)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring()) {
                isPressed = false
            }
        }
    }

    private func showDelta(_ delta: Int) {
        deltaTask?.cancel()
        withAnimation(.easeOut(duration: 0.15)) {
            deltaText = delta >= 0 ? "+\(delta)" : "\(delta)"
        }
        deltaTask = Task {
            try? await Task.sleep(nanoseconds: 550_000_000)
            if !Task.isCancelled {
                withAnimation(.easeIn(duration: 0.2)) {
                    deltaText = nil
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TapFrenzyView()
    }
}
