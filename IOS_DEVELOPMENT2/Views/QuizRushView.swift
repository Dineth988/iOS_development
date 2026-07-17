import SwiftUI

private enum RushTheme {
    static let backgroundTop = Color(red: 0.11, green: 0.09, blue: 0.20)
    static let backgroundBottom = Color(red: 0.15, green: 0.11, blue: 0.27)
    static let surface = Color.white.opacity(0.06)
    static let surfaceStroke = Color.white.opacity(0.10)
    static let textPrimary = Color(red: 0.96, green: 0.95, blue: 1.0)
    static let textSecondary = Color(red: 0.66, green: 0.62, blue: 0.78)
    static let volt = Color(red: 0.85, green: 1.0, blue: 0.36)
    static let flame = Color(red: 1.0, green: 0.30, blue: 0.44)
}

struct QuizRushView: View {
    @StateObject private var viewModel = QuizViewModel()

    @State private var pressedAnswer: String?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [RushTheme.backgroundTop, RushTheme.backgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                switch viewModel.state {
                case .selecting:
                    setupView
                case .loading:
                    loadingView
                case .failed:
                    failedView
                case .loaded:
                    if viewModel.isRoundOver {
                        resultsView
                    } else if !viewModel.questions.isEmpty {
                        quizContent
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .task {
            await viewModel.loadCategories()
        }
    }

    // MARK: - Setup

    private var setupView: some View {
        VStack(spacing: 20) {
            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 34))
                    .foregroundColor(RushTheme.volt)
                Text("Set Up Your Rush")
                    .font(.system(.title2, design: .rounded))
                    .bold()
                    .foregroundColor(RushTheme.textPrimary)
                Text("Pick a category and difficulty to begin.")
                    .font(.subheadline)
                    .foregroundColor(RushTheme.textSecondary)
            }

            VStack(spacing: 14) {
                settingRow(label: "Category") {
                    Menu {
                        Button("Any Category") {
                            viewModel.selectedCategory = nil
                        }
                        ForEach(viewModel.categories) { category in
                            Button(category.name) {
                                viewModel.selectedCategory = category
                            }
                        }
                    } label: {
                        menuLabel(viewModel.selectedCategory?.name ?? "Any Category")
                    }
                    .disabled(viewModel.categories.isEmpty)
                }

                settingRow(label: "Difficulty") {
                    Menu {
                        ForEach(Difficulty.allCases) { difficulty in
                            Button(difficulty.label) {
                                viewModel.selectedDifficulty = difficulty
                            }
                        }
                    } label: {
                        menuLabel(viewModel.selectedDifficulty.label)
                    }
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(RushTheme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(RushTheme.surfaceStroke, lineWidth: 1)
                    )
            )

            if viewModel.categories.isEmpty && !viewModel.categoriesLoadFailed {
                ProgressView()
                    .tint(RushTheme.volt)
            }

            if viewModel.categoriesLoadFailed {
                VStack(spacing: 8) {
                    Text("Couldn't load categories")
                        .font(.subheadline)
                        .foregroundColor(RushTheme.textSecondary)
                    Button("Retry") {
                        Task { await viewModel.loadCategories() }
                    }
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(RushTheme.volt)
                }
            }

            Button {
                Task { await viewModel.load() }
            } label: {
                Text("Start Quiz")
                    .font(.system(.headline, design: .rounded))
                    .frame(maxWidth: 220)
            }
            .buttonStyle(.borderedProminent)
            .tint(RushTheme.volt)
            .foregroundColor(.black)
            .controlSize(.large)

            Spacer()
        }
    }

    private func settingRow<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(label)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(RushTheme.textSecondary)
            Spacer()
            content()
        }
    }

    private func menuLabel(_ text: String) -> some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.medium)
                .foregroundColor(RushTheme.textPrimary)
                .lineLimit(1)
            Image(systemName: "chevron.up.chevron.down")
                .font(.caption2)
                .foregroundColor(RushTheme.textSecondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.05))
        )
    }

    // MARK: - Loading / Failed

    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .tint(RushTheme.volt)
                .scaleEffect(1.4)
            Text("Loading questions…")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(RushTheme.textSecondary)
            Spacer()
        }
    }

    private var failedView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bolt.slash.fill")
                .font(.system(size: 40))
                .foregroundColor(RushTheme.flame)
            Text("Couldn't load questions")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(RushTheme.textPrimary)
            Text("Check your connection and try again.")
                .font(.subheadline)
                .foregroundColor(RushTheme.textSecondary)
            HStack(spacing: 12) {
                Button {
                    Task { await viewModel.load() }
                } label: {
                    Text("Retry")
                        .font(.system(.headline, design: .rounded))
                        .frame(maxWidth: 140)
                }
                .buttonStyle(.borderedProminent)
                .tint(RushTheme.volt)
                .foregroundColor(.black)
                .controlSize(.large)

                Button {
                    viewModel.backToSetup()
                } label: {
                    Text("Change Settings")
                        .font(.system(.headline, design: .rounded))
                        .frame(maxWidth: 180)
                }
                .buttonStyle(.bordered)
                .tint(RushTheme.textSecondary)
                .controlSize(.large)
            }
            Spacer()
        }
    }

    // MARK: - Results

    private var resultsView: some View {
        VStack(spacing: 20) {
            Spacer()
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(RushTheme.volt.opacity(0.15))
                        .frame(width: 84, height: 84)
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 34))
                        .foregroundColor(RushTheme.volt)
                }

                Text("Quiz Complete")
                    .font(.system(.title2, design: .rounded))
                    .bold()
                    .foregroundColor(RushTheme.textPrimary)

                HStack(spacing: 28) {
                    statBlock(label: "SCORE", value: "\(viewModel.score)")
                    Divider()
                        .frame(height: 32)
                        .background(RushTheme.surfaceStroke)
                    statBlock(label: "BEST STREAK", value: "\(viewModel.streak)")
                }

                VStack(spacing: 10) {
                    Button {
                        Task { await viewModel.load() }
                    } label: {
                        Text("Play Again")
                            .font(.system(.headline, design: .rounded))
                            .frame(maxWidth: 220)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(RushTheme.volt)
                    .foregroundColor(.black)
                    .controlSize(.large)

                    Button {
                        viewModel.backToSetup()
                    } label: {
                        Text("Change Settings")
                            .font(.system(.subheadline, design: .rounded))
                    }
                    .foregroundColor(RushTheme.textSecondary)
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(RushTheme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(RushTheme.surfaceStroke, lineWidth: 1)
                    )
            )
            .transition(.scale.combined(with: .opacity))
            Spacer()
        }
    }

    private func statBlock(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.title2, design: .rounded))
                .bold()
                .foregroundColor(RushTheme.textPrimary)
            Text(label)
                .font(.caption2)
                .fontWeight(.semibold)
                .tracking(0.5)
                .foregroundColor(RushTheme.textSecondary)
        }
    }

    // MARK: - Quiz content (unchanged)

    private var quizContent: some View {
        VStack(spacing: 24) {
            progressHeader

            Spacer(minLength: 4)

            Text(viewModel.questions[viewModel.currentIndex].question)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(RushTheme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity)
                .fixedSize(horizontal: false, vertical: true)
                .id(viewModel.currentIndex)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

            Spacer(minLength: 4)

            VStack(spacing: 12) {
                ForEach(viewModel.answers, id: \.self) { answer in
                    answerButton(answer)
                }
            }
            .padding(.bottom, 6)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.currentIndex)
    }

    private var progressHeader: some View {
        VStack(spacing: 14) {
            HStack(spacing: 5) {
                ForEach(0..<viewModel.questions.count, id: \.self) { index in
                    Capsule()
                        .fill(index <= viewModel.currentIndex ? RushTheme.volt : RushTheme.surface)
                        .frame(height: 6)
                        .shadow(color: index == viewModel.currentIndex ? RushTheme.volt.opacity(0.7) : .clear, radius: 4)
                }
            }
            .animation(.easeOut(duration: 0.3), value: viewModel.currentIndex)

            HStack {
                Text("Question \(viewModel.currentIndex + 1) of \(viewModel.questions.count)")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(RushTheme.textSecondary)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(viewModel.streak > 0 ? RushTheme.flame : RushTheme.textSecondary.opacity(0.4))
                        .scaleEffect(viewModel.streak > 0 ? 1.0 : 0.85)
                    Text("\(viewModel.streak)")
                        .font(.system(.caption, design: .rounded))
                        .bold()
                        .foregroundColor(viewModel.streak > 0 ? RushTheme.flame : RushTheme.textSecondary)
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: viewModel.streak)

                Spacer()

                Text("\(viewModel.score) pts")
                    .font(.system(.caption, design: .rounded))
                    .bold()
                    .foregroundColor(RushTheme.textPrimary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(RushTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(RushTheme.surfaceStroke, lineWidth: 1)
                )
        )
    }

    private func answerButton(_ answer: String) -> some View {
        Button {
            pressedAnswer = answer
            withAnimation(.easeOut(duration: 0.12)) {
                pressedAnswer = answer
            }
            viewModel.submitAnswer(answer)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                pressedAnswer = nil
            }
        } label: {
            HStack {
                Text(answer)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(pressedAnswer == answer ? RushTheme.volt.opacity(0.18) : RushTheme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(pressedAnswer == answer ? RushTheme.volt : RushTheme.surfaceStroke, lineWidth: 1.5)
                    )
            )
            .foregroundColor(RushTheme.textPrimary)
            .scaleEffect(pressedAnswer == answer ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        QuizRushView()
    }
}
